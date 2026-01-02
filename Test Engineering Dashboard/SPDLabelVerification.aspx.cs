using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Security;
using System.Web.UI;
using TED;

public partial class TED_SPDLabelVerification : Page
{
    private const string SessionKeySerial = "SPD:Serial";
    private const string SessionKeyCatalog = "SPD:Catalog";
    private const string SessionKeyWorkcell = "SPD:Workcell";

    private readonly SpdLabelVerificationService _service = new SpdLabelVerificationService();

    protected void Page_Load(object sender, EventArgs e)
    {
        RefreshUI();
        FocusControl(HasSerial() ? txtMaterial : txtSerial);
    }

    protected void txtSerial_TextChanged(object sender, EventArgs e)
    {
        var serial = (txtSerial.Text ?? string.Empty).Trim();
        if (string.IsNullOrEmpty(serial))
        {
            ShowToast("Please scan the serial number.", false);
            FocusControl(txtSerial);
            return;
        }

        var result = _service.GetLatestPassedTest(serial);
        if (!result.Success)
        {
            ShowToast(result.Error, false);
            FocusControl(txtSerial);
            return;
        }

        var info = result.Data;
        Session[SessionKeySerial] = info.SerialNumber;
        Session[SessionKeyCatalog] = info.CatalogNumber;
        Session[SessionKeyWorkcell] = info.Workcell;
        txtMaterial.Text = string.Empty;

        RefreshUI();
        ShowToast(string.Format("Serial {0} ready. Scan the material number.", info.SerialNumber), true);
        FocusControl(txtMaterial);
    }

    protected void txtMaterial_TextChanged(object sender, EventArgs e)
    {
        if (!HasSerial())
        {
            ShowToast("Scan the serial first so we know which catalog to validate.", false);
            txtMaterial.Text = string.Empty;
            FocusControl(txtSerial);
            return;
        }

        var material = (txtMaterial.Text ?? string.Empty).Trim();
        if (string.IsNullOrEmpty(material))
        {
            ShowToast("Please scan the material number.", false);
            FocusControl(txtMaterial);
            return;
        }

        var catalog = Session[SessionKeyCatalog] as string;
        var lookup = _service.LookupMaterialNumber(catalog);
        if (!lookup.Success)
        {
            ShowToast(lookup.Error, false);
            FocusControl(txtMaterial);
            return;
        }

        var expected = (lookup.Data.MaterialNumber ?? string.Empty).Trim();
        bool match = string.Equals(material, expected, StringComparison.OrdinalIgnoreCase);

        var historyRecord = new HistoryRecord
        {
            Timestamp = DateTime.Now,
            Operator = CurrentOperatorName,
            Badge = CurrentOperatorENumber,
            Serial = Session[SessionKeySerial] as string,
            Catalog = catalog,
            MaterialScanned = material,
            MaterialExpected = expected,
            Workcell = Session[SessionKeyWorkcell] as string,
            IsMatch = match
        };

        SaveValidationRecord(historyRecord);

        ClearScanState();
        RefreshUI();

        var statusMessage = match ? "Label verified. Send unit to shipping." : "Mismatch! Re-scan or reprint the label.";
        HideToast();
        ShowResultOverlay(statusMessage, match);
        FocusControl(txtSerial);
    }

    protected void btnReport_Click(object sender, EventArgs e)
    {
        Response.Redirect("~/SPDLabelDashboard.aspx", false);
    }

    protected void btnLogout_Click(object sender, EventArgs e)
    {
        Session.Clear();
        Session.Abandon();
        FormsAuthentication.SignOut();

        var returnUrl = ResolveUrl("~/SPDLabelVerification.aspx");
        var loginUrlSetting = FormsAuthentication.LoginUrl;
        if (string.IsNullOrWhiteSpace(loginUrlSetting))
        {
            loginUrlSetting = "~/Account/Login.aspx";
        }

        var loginUrl = ResolveUrl(loginUrlSetting);
        var separator = loginUrl.Contains("?") ? "&" : "?";
        var redirectUrl = string.Format("{0}{1}ReturnUrl={2}", loginUrl, separator, Server.UrlEncode(returnUrl));
        Response.Redirect(redirectUrl, true);
    }

    private void RefreshUI()
    {
        var history = LoadTodaysValidations();
        rptHistory.DataSource = history;
        rptHistory.DataBind();
        pnlHistoryEmpty.Visible = !history.Any();
        if (litHistoryDate != null)
        {
            litHistoryDate.Text = " (" + DateTime.Today.ToString("MM/dd/yyyy") + ")";
        }
        UpdateUserInfo();
        UpdateInputStates();
        HideToast();
        if (pnlResultOverlay != null)
        {
            pnlResultOverlay.Visible = false;
            pnlResultOverlay.CssClass = "result-overlay";
            if (pnlOverlayCard != null)
            {
                pnlOverlayCard.CssClass = "overlay-panel";
            }
        }
    }

    private void UpdateUserInfo()
    {
        if (litUserName == null || litUserBadge == null || litUserInitials == null)
        {
            return;
        }

        var operatorName = CurrentOperatorName;
        var badge = CurrentOperatorENumber;

        litUserName.Text = operatorName;
        litUserBadge.Text = string.IsNullOrWhiteSpace(badge) ? "Unavailable" : badge;
        litUserInitials.Text = BuildInitials(operatorName, badge);
    }

    private void UpdateInputStates()
    {
        var hasSerial = HasSerial();
        txtMaterial.Enabled = hasSerial;
        if (pnlMaterialCard != null)
        {
            var baseClass = "scan-card step-card";
            pnlMaterialCard.CssClass = hasSerial ? baseClass : baseClass + " card-disabled";
        }
    }

    private static string BuildInitials(string name, string badge)
    {
        if (!string.IsNullOrWhiteSpace(name))
        {
            var segments = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (segments.Length == 1)
            {
                var single = segments[0];
                return single.Substring(0, Math.Min(2, single.Length)).ToUpperInvariant();
            }

            var first = segments[0];
            var last = segments[segments.Length - 1];
            var firstInitial = string.IsNullOrEmpty(first) ? '-' : first[0];
            var lastInitial = string.IsNullOrEmpty(last) ? '-' : last[0];
            var initials = string.Concat(firstInitial, lastInitial);
            return initials.ToUpperInvariant();
        }

        if (!string.IsNullOrWhiteSpace(badge))
        {
        return badge.Substring(0, Math.Min(2, badge.Length)).ToUpperInvariant();
    }

    return "--";
}

protected string RenderWorkcellChip(object workcellValue)
{
    var workcell = Convert.ToString(workcellValue);
    if (string.IsNullOrWhiteSpace(workcell))
    {
        return "--";
    }

    var normalized = workcell.Trim().ToLowerInvariant();
    if (normalized == "integrated")
    {
        return "<span class='workcell-chip integrated'>Integrated</span>";
    }
    else if (normalized == "sidemount")
    {
        return "<span class='workcell-chip sidemount'>Sidemount</span>";
    }
    else
    {
        return workcell;
    }
}    private bool HasSerial()
    {
        return Session[SessionKeySerial] != null && Session[SessionKeyCatalog] != null;
    }

    private void ClearScanState()
    {
        txtSerial.Text = string.Empty;
        txtMaterial.Text = string.Empty;
        Session.Remove(SessionKeySerial);
        Session.Remove(SessionKeyCatalog);
        Session.Remove(SessionKeyWorkcell);
    }

    private void ShowToast(string message, bool success)
    {
        pnlToast.Visible = true;
        pnlToast.CssClass = success ? "toast toast-success show" : "toast toast-error show";
        litToast.Text = message;
        var script = string.Format("setTimeout(function(){{var toast=document.getElementById('{0}');if(toast){{toast.classList.remove('show');}}}}, 4500);", pnlToast.ClientID);
        ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
    }

    private void HideToast()
    {
        if (pnlToast == null)
        {
            return;
        }

        pnlToast.Visible = false;
        pnlToast.CssClass = "toast";
        litToast.Text = string.Empty;
    }

        private void ShowResultOverlay(string message, bool success)
        {
                if (pnlResultOverlay == null || pnlOverlayCard == null || litOverlayTitle == null || litOverlayMessage == null)
                {
                        ShowToast(message, success);
                        return;
                }

                pnlResultOverlay.Visible = true;
                pnlResultOverlay.CssClass = "result-overlay show";
                pnlOverlayCard.CssClass = success ? "overlay-panel pass" : "overlay-panel fail";
                litOverlayTitle.Text = success ? "PASS" : "FAIL";
                litOverlayMessage.Text = message;

                var script = string.Format(@"
                    (function() {{
                        var overlay = document.getElementById('{0}');
                        if(!overlay) return;
                        setTimeout(function() {{ overlay.classList.remove('show'); }}, 4800);
                    }})();", pnlResultOverlay.ClientID);

                ScriptManager.RegisterStartupScript(this, GetType(), Guid.NewGuid().ToString("N"), script, true);
        }

    private void FocusControl(Control control)
    {
        if (control == null) return;
        var script = string.Format("spdFocusField('{0}');", control.ClientID);
        ScriptManager.RegisterStartupScript(this, control.GetType(), Guid.NewGuid().ToString("N"), script, true);
    }

    private void SaveValidationRecord(HistoryRecord record)
    {
        var settings = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString) || record == null)
        {
            return;
        }

        try
        {
            using (var conn = new SqlConnection(settings.ConnectionString))
            using (var cmd = new SqlCommand(@"INSERT INTO dbo.SPDLabelValidations
                (ValidationTime, OperatorName, OperatorENumber, SerialNumber, CatalogNumber, MaterialScanned, MaterialExpected, IsMatch, Workcell)
                VALUES (@ValidationTime, @OperatorName, @OperatorENumber, @SerialNumber, @CatalogNumber, @MaterialScanned, @MaterialExpected, @IsMatch, @Workcell);", conn))
            {
                cmd.Parameters.Add("@ValidationTime", SqlDbType.DateTime).Value = record.Timestamp;
                cmd.Parameters.Add("@OperatorName", SqlDbType.NVarChar, 100).Value = (object)record.Operator ?? DBNull.Value;
                cmd.Parameters.Add("@OperatorENumber", SqlDbType.NVarChar, 50).Value = (object)record.Badge ?? DBNull.Value;
                cmd.Parameters.Add("@SerialNumber", SqlDbType.NVarChar, 50).Value = (object)record.Serial ?? DBNull.Value;
                cmd.Parameters.Add("@CatalogNumber", SqlDbType.NVarChar, 50).Value = (object)record.Catalog ?? DBNull.Value;
                cmd.Parameters.Add("@MaterialScanned", SqlDbType.NVarChar, 100).Value = (object)record.MaterialScanned ?? DBNull.Value;
                cmd.Parameters.Add("@MaterialExpected", SqlDbType.NVarChar, 100).Value = (object)record.MaterialExpected ?? DBNull.Value;
                cmd.Parameters.Add("@IsMatch", SqlDbType.Bit).Value = record.IsMatch;
                cmd.Parameters.Add("@Workcell", SqlDbType.NVarChar, 50).Value = (object)record.Workcell ?? DBNull.Value;

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch (SqlException ex)
        {
            System.Diagnostics.Trace.WriteLine("[SPD] Unable to log label validation: " + ex.Message);
        }
    }

    private IList<HistoryRecord> LoadTodaysValidations()
    {
        var records = new List<HistoryRecord>();
        var settings = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"];
        if (settings == null || string.IsNullOrWhiteSpace(settings.ConnectionString))
        {
            return records;
        }

        var start = DateTime.Today;
        var end = start.AddDays(1);

        try
        {
            using (var conn = new SqlConnection(settings.ConnectionString))
            using (var cmd = new SqlCommand(@"SELECT TOP 200 ValidationTime, OperatorName, OperatorENumber, SerialNumber, CatalogNumber, MaterialScanned, MaterialExpected, IsMatch, Workcell
                                             FROM dbo.SPDLabelValidations
                                             WHERE ValidationTime >= @Start AND ValidationTime < @End
                                             ORDER BY ValidationTime DESC", conn))
            {
                cmd.Parameters.Add("@Start", SqlDbType.DateTime).Value = start;
                cmd.Parameters.Add("@End", SqlDbType.DateTime).Value = end;

                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        records.Add(new HistoryRecord
                        {
                            Timestamp = reader.GetDateTime(reader.GetOrdinal("ValidationTime")),
                            Operator = ReadNullableString(reader, "OperatorName"),
                            Badge = ReadNullableString(reader, "OperatorENumber"),
                            Serial = ReadNullableString(reader, "SerialNumber"),
                            Catalog = ReadNullableString(reader, "CatalogNumber"),
                            MaterialScanned = ReadNullableString(reader, "MaterialScanned"),
                            MaterialExpected = ReadNullableString(reader, "MaterialExpected"),
                            Workcell = ReadNullableString(reader, "Workcell"),
                            IsMatch = !reader.IsDBNull(reader.GetOrdinal("IsMatch")) && reader.GetBoolean(reader.GetOrdinal("IsMatch"))
                        });
                    }
                }
            }
        }
        catch (SqlException ex)
        {
            System.Diagnostics.Trace.WriteLine("[SPD] Unable to load label validations: " + ex.Message);
        }

        return records;
    }

    private static string ReadNullableString(IDataRecord record, string fieldName)
    {
        if (record == null || string.IsNullOrWhiteSpace(fieldName))
        {
            return null;
        }

        try
        {
            int ordinal = record.GetOrdinal(fieldName);
            if (record.IsDBNull(ordinal))
            {
                return null;
            }
            return Convert.ToString(record.GetValue(ordinal));
        }
        catch (IndexOutOfRangeException)
        {
            return null;
        }
    }

    private string CurrentOperatorName
    {
        get
        {
            var nameValue = Session["TED:FullName"] as string;
            var name = string.IsNullOrEmpty(nameValue) ? nameValue : nameValue.Trim();
            if (string.IsNullOrEmpty(name))
            {
                name = Context.User != null ? Context.User.Identity.Name : string.Empty;
            }
            return string.IsNullOrWhiteSpace(name) ? "Authenticated User" : name;
        }
    }

    private string CurrentOperatorENumber
    {
        get
        {
            var badgeValue = Session["TED:ENumber"] as string;
            var badge = string.IsNullOrEmpty(badgeValue) ? badgeValue : badgeValue.Trim();
            if (string.IsNullOrEmpty(badge))
            {
                var emailValue = Session["TED:Email"] as string;
                badge = string.IsNullOrEmpty(emailValue) ? emailValue : emailValue.Trim();
            }
            return badge ?? string.Empty;
        }
    }

    [Serializable]
    public class HistoryRecord
    {
        public DateTime Timestamp { get; set; }
        public string Operator { get; set; }
        public string Badge { get; set; }
        public string Serial { get; set; }
        public string Catalog { get; set; }
        public string MaterialScanned { get; set; }
        public string MaterialExpected { get; set; }
        public string Workcell { get; set; }
        public bool IsMatch { get; set; }
    }
}
