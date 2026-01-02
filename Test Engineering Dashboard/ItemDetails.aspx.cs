using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Collections.Generic;
using System.IO;

public partial class ItemDetails : System.Web.UI.Page
{
    private string CurrentType
    {
        get { return Request.QueryString["type"] ?? (ViewState["type"] as string) ?? "ATE"; }
        set { ViewState["type"] = value; }
    }

    private string CurrentKey
    {
        get
        {
            // On initial load, check query string
            if (!IsPostBack && Request.QueryString["id"] != null)
            {
                return Request.QueryString["id"];
            }

            // On postback, check ViewState first, then dropdown value
            string viewStateKey = ViewState["key"] as string;
            if (!string.IsNullOrEmpty(viewStateKey))
            {
                return viewStateKey;
            }

            // Fallback to dropdown value if ViewState is empty
            if (IsPostBack && ddlItemSelect != null && !string.IsNullOrEmpty(ddlItemSelect.SelectedValue))
            {
                return ddlItemSelect.SelectedValue;
            }

            return string.Empty;
        }
        set { ViewState["key"] = value; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            CurrentType = (Request.QueryString["type"] ?? "ATE").Trim();
            CurrentKey = (Request.QueryString["id"] ?? string.Empty).Trim();
        }
        hfType.Value = CurrentType;
        hfKey.Value = CurrentKey ?? string.Empty;

        BuildForm(CurrentType);
    }

    private string PreviousSelection
    {
        get { return ViewState["prevSelection"] as string ?? string.Empty; }
        set { ViewState["prevSelection"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            BindItemDropdown();
            LoadItemData();
            PreviousSelection = CurrentKey;
        }
        else
        {
            // Re-bind dropdown to maintain items across postback
            BindItemDropdown();

            // Check if this is a Save button postback - if so, don't reload data
            bool isSavePostback = Request.Form["__EVENTTARGET"] != null && 
                                  (Request.Form["__EVENTTARGET"].Contains("btnSave") || 
                                   Request.Form["__EVENTTARGET"].Contains("btnDeleteTop"));
            
            if (!isSavePostback)
            {
                // Check if dropdown selection changed by looking at posted value
                string postedValue = Request.Form[ddlItemSelect.UniqueID];
                if (!string.IsNullOrEmpty(postedValue) && postedValue != PreviousSelection && postedValue != "")
                {
                    CurrentKey = postedValue;
                    ddlItemSelect.SelectedValue = postedValue; // Update the dropdown selection
                    LoadItemData();
                    PreviousSelection = postedValue;
                }
                else if (!string.IsNullOrEmpty(CurrentKey))
                {
                    LoadItemData();
                }
            }

            // Re-initialize multi-selects after postback to restore JS behaviors
            Page.ClientScript.RegisterStartupScript(this.GetType(), "reinitMultiSelect",
                "setTimeout(initializeAllMultiSelects, 100);", true);
        }
    }

    private bool CanEdit()
    {
        var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
        var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
        return (cat.Contains("admin") || cat.Contains("test engineering") || role.Contains("admin") || role.Contains("test engineering"));
    }

    private void BindItemDropdown()
    {
        // Preserve current selection before clearing
        string currentSelection = ddlItemSelect.SelectedValue;

        ddlItemSelect.Items.Clear();
        ddlItemSelect.Items.Add(new ListItem("Select Eaton ID...", ""));

        try
        {
            using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString))
            using (var cmd = new SqlCommand(GetSelectIdsWithNameQuery(CurrentType), conn))
            {
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var id = rdr[0] as string;
                        var name = rdr.FieldCount > 1 ? (rdr.IsDBNull(1) ? null : rdr[1].ToString()) : null;
                        if (!string.IsNullOrEmpty(id))
                        {
                            var text = !string.IsNullOrWhiteSpace(name) ? (id + " / " + name) : id;
                            ddlItemSelect.Items.Add(new ListItem(text, id));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowBanner("Error loading items: " + ex.Message, "error");
        }

        // Restore selection - prefer CurrentKey, fallback to preserved selection
        string selectionToRestore = !string.IsNullOrEmpty(CurrentKey) ? CurrentKey : currentSelection;
        if (!string.IsNullOrEmpty(selectionToRestore))
        {
            var item = ddlItemSelect.Items.FindByValue(selectionToRestore);
            if (item != null)
            {
                ddlItemSelect.SelectedValue = selectionToRestore;
            }
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        // Disable editing if user lacks permissions
        if (!CanEdit())
        {
            // Only disable the editable form fields. Keep Eaton ID dropdown enabled for all users.
            if (phFormFields != null) DisableInputs(phFormFields);
            // Disable action buttons except navigation
            var save = FindControlRecursive(this, "btnSave") as LinkButton;
            var del = FindControlRecursive(this, "btnDelete") as LinkButton;
            if (save != null)
            {
                save.Attributes["aria-disabled"] = "true";
                save.OnClientClick = "return false;";
            }
            if (del != null)
            {
                del.Attributes["aria-disabled"] = "true";
                del.OnClientClick = "return false;";
            }
        }
    }

    protected void btnDeleteTop_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(CurrentKey)) { ShowBanner("No item selected to delete.", "error"); return; }
            DeleteItem(CurrentType, CurrentKey);
            // Redirect with success message instead of showing banner (since page won't exist after delete)
            Response.Redirect("EquipmentInventoryDashboard.aspx?msg=deleted&type=" + CurrentType);
        }
        catch (Exception ex)
        {
            ShowBanner("Delete failed: " + ex.Message, "error");
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        try
        {
            if (string.IsNullOrEmpty(CurrentKey)) { ShowBanner("Select an item to save.", "info"); return; }
            
            // Server-side validation for PM Responsible
            bool requiredPM = GetBool("chkRequiredPM");
            if (requiredPM)
            {
                string pmResponsible = GetMultiCsvFromControls("msPMResponsible");
                if (string.IsNullOrWhiteSpace(pmResponsible))
                {
                    ShowBanner("PM Responsible is required when Required PM is enabled.", "error");
                    return;
                }
            }
            
            SaveItem(CurrentType, CurrentKey);
            ShowBanner("Changes saved successfully.", null);
            LoadItemData();
        }
        catch (Exception ex)
        {
            ShowBanner("Save failed: " + ex.Message, "error");
        }
    }

    private void BuildForm(string type)
    {
        phFormFields.Controls.Clear();
        // Reuse CreateNewItem control factory styles and grid (3 per row -> span-4)
        // For brevity here, we generate placeholders; detailed per-field binding happens in Load/Save
        var grid = new Panel { CssClass = "form-grid" };
        phFormFields.Controls.Add(grid);

        // Create type-specific form structure
        if (string.Equals(type, "ATE", StringComparison.OrdinalIgnoreCase))
        {
            // Row 1: Eaton ID | ATE Name | ATE Description
            AddRow(grid, CreateText("txtEatonID", "Eaton ID", true), CreateText("txtATEName", "ATE Name", false), CreateText("txtATEDescription", "ATE Description", false));
            // Row 2: Location | ATE Folder | ATE Status
            AddRow(grid, CreateDropdown("ddlLocation", "Location"), CreateUrl("txtATEFolder", "ATE Folder", true), CreateDropdown("ddlATEStatus", "ATE Status"));
            // Row 3: Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
            AddCalPMRow(grid, CreateToggle("chkRequiresCalibration", "Requires Calibration"), CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false), CreateText("txtCalibrationID", "Calibration ID", false), CreateDropdown("ddlCalFreq", "Calibration Frequency"));
            // Row 4: Last Calibration | Calibrated By | Next Calibration
            AddRow(grid, CreateReadOnly("txtLastCal", "Last Calibration"), CreateReadOnly("txtCalBy", "Calibrated By"), CreateReadOnly("txtNextCal", "Next Calibration"));
            // Row 5: Required PM + PM Est Time | PM Frequency | PM Responsible
            AddCalPMRow(grid, CreateToggle("chkRequiredPM", "Required PM"), CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false), CreateDropdown("ddlPMFreq", "PM Frequency"), CreateMultiUsers("msPMResponsible", "PM Responsible"));
            // Row 6: Last PM | Last PM By | Next PM
            AddRow(grid, CreateReadOnly("txtLastPM", "Last PM"), CreateReadOnly("txtLastPMBy", "Last PM By"), CreateReadOnly("txtNextPM", "Next PM"));
            // Row 7 (Image + Comments - image span-4, comments span-8)
            var ateImg = CreateFile("fuATEImage", "ATE Image"); var comments = CreateTextArea("txtComments", "Comments");
            AddRow(grid, ateImg, comments);
        }
        else if (string.Equals(type, "Asset", StringComparison.OrdinalIgnoreCase))
        {
            // Row 1: Eaton ID | Model No | Device Name
            AddRow(grid, CreateText("txtEatonID", "Eaton ID", true), CreateText("txtModelNo", "Model No", false), CreateText("txtDeviceName", "Device Name", false));
            // Row 2: Device Description | ATE | Location
            AddRow(grid, CreateText("txtDeviceDescription", "Device Decription", false), CreateDropdown("ddlATE", "ATE"), CreateDropdown("ddlLocation", "Location"));
            // Row 3: Device Type | Manufacturer | Manufacturer Site
            AddRow(grid, CreateDropdown("ddlDeviceType", "Device Type", true), CreateDropdown("ddlManufacturer", "Manufacturer"), CreateUrl("txtManufacturerSite", "Manufacturer Site"));
            // Row 4: Device Folder | Current Status | Swap Capability
            AddRow(grid, CreateUrl("txtDeviceFolder", "Device Folder", true), CreateDropdown("ddlCurrentStatus", "Current Status"), CreateMultiAssets("msSwapCapability", "Swap Capability"));
            // Row 5: Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
            AddCalPMRow(grid, CreateToggle("chkRequiresCalibration", "Requires Calibration"), CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false), CreateText("txtCalibrationID", "Calibration ID", false), CreateDropdown("ddlCalFreq", "Calibration Frequency"));
            // Row 6: Last Calibration | Calibrated By | Next Calibration
            AddRow(grid, CreateReadOnly("txtLastCal", "Last Calibration"), CreateReadOnly("txtCalBy", "Calibrated By"), CreateReadOnly("txtNextCal", "Next Calibration"));
            // Row 7: Required PM + PM Est Time | PM Frequency | PM Responsible
            AddCalPMRow(grid, CreateToggle("chkRequiredPM", "Required PM"), CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false), CreateDropdown("ddlPMFreq", "PM Frequency"), CreateMultiUsers("msPMResponsible", "PM Responsible"));
            // Row 8: Last PM | Last PM By | Next PM
            AddRow(grid, CreateReadOnly("txtLastPM", "Last PM"), CreateReadOnly("txtLastPMBy", "Last PM By"), CreateReadOnly("txtNextPM", "Next PM"));
            // Row 9 (Device Image + Comments - image span-4, comments span-8)
            AddRow(grid, CreateFile("fuDeviceImage", "Device Image"), CreateTextArea("txtComments", "Comments"));
        }
        else if (string.Equals(type, "Fixture", StringComparison.OrdinalIgnoreCase))
        {
            // Row 1: Eaton ID | Fixture Model | Fixture Description
            AddRow(grid, CreateText("txtEatonID", "Eaton ID", true), CreateText("txtFixtureModel", "Fixture Model No. / Name", false), CreateText("txtFixtureDescription", "Fixture Description", false));
            // Row 2: Location | Fixture Folder | Current Status
            AddRow(grid, CreateDropdown("ddlLocation", "Location"), CreateUrl("txtFixtureFolder", "Fixture Folder", true), CreateDropdown("ddlCurrentStatus", "Current Status"));
            // Row 3: Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
            AddCalPMRow(grid, CreateToggle("chkRequiresCalibration", "Requires Calibration"), CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false), CreateText("txtCalibrationID", "Calibration ID", false), CreateDropdown("ddlCalFreq", "Calibration Frequency"));
            // Row 4: Last Calibration | Calibrated By | Next Calibration
            AddRow(grid, CreateReadOnly("txtLastCal", "Last Calibration"), CreateReadOnly("txtCalBy", "Calibrated By"), CreateReadOnly("txtNextCal", "Next Calibration"));
            // Row 5: Required PM + PM Est Time | PM Frequency | PM Responsible
            AddCalPMRow(grid, CreateToggle("chkRequiredPM", "Required PM"), CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false), CreateDropdown("ddlPMFreq", "PM Frequency"), CreateMultiUsers("msPMResponsible", "PM Responsible"));
            // Row 6: Last PM | Last PM By | Next PM
            AddRow(grid, CreateReadOnly("txtLastPM", "Last PM"), CreateReadOnly("txtLastPMBy", "Last PM By"), CreateReadOnly("txtNextPM", "Next PM"));
            // Row 7 (Image + Comments - image span-4, comments span-8)
            var fixImg = CreateFile("fuFixtureImage", "Fixture Image"); var comments = CreateTextArea("txtComments", "Comments");
            AddRow(grid, fixImg, comments);
        }
        else if (string.Equals(type, "Harness", StringComparison.OrdinalIgnoreCase))
        {
            // Row 1: Eaton ID | Harness Model | Harness Description
            AddRow(grid, CreateText("txtEatonID", "Eaton ID", true), CreateText("txtHarnessModel", "Harness Model No.", false), CreateText("txtHarnessDescription", "Harness Description", false));
            // Row 2: Location | Harness Folder | Current Status
            AddRow(grid, CreateDropdown("ddlLocation", "Location"), CreateUrl("txtHarnessFolder", "Harness Folder", true), CreateDropdown("ddlCurrentStatus", "Current Status"));
            // Row 3: Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
            AddCalPMRow(grid, CreateToggle("chkRequiresCalibration", "Requires Calibration"), CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false), CreateText("txtCalibrationID", "Calibration ID", false), CreateDropdown("ddlCalFreq", "Calibration Frequency"));
            // Row 4: Last Calibration | Calibrated By | Next Calibration
            AddRow(grid, CreateReadOnly("txtLastCal", "Last Calibration"), CreateReadOnly("txtCalBy", "Calibrated By"), CreateReadOnly("txtNextCal", "Next Calibration"));
            // Row 5: Required PM + PM Est Time | PM Frequency | PM Responsible
            AddCalPMRow(grid, CreateToggle("chkRequiredPM", "Required PM"), CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false), CreateDropdown("ddlPMFreq", "PM Frequency"), CreateMultiUsers("msPMResponsible", "PM Responsible"));
            // Row 6: Last PM | Last PM By | Next PM
            AddRow(grid, CreateReadOnly("txtLastPM", "Last PM"), CreateReadOnly("txtLastPMBy", "Last PM By"), CreateReadOnly("txtNextPM", "Next PM"));
            // Row 7 (Image + Comments - image span-4, comments span-8)
            var hImg = CreateFile("fuHarnessImage", "Harness Image"); var comments = CreateTextArea("txtComments", "Comments");
            AddRow(grid, hImg, comments);
        }

        // Populate dropdowns after controls exist
        PopulateCommonDropdowns();
    }

    private void PopulateCommonDropdowns()
    {
        // Location
        var ddlLoc = FindControlRecursive(phFormFields, "ddlLocation") as DropDownList; if (ddlLoc != null) PopulateLocationDropdown(ddlLoc);
        // ATE Status
        var ddlATEStatus = FindControlRecursive(phFormFields, "ddlATEStatus") as DropDownList; if (ddlATEStatus != null) PopulateATEStatusDropdown(ddlATEStatus);
        // Current Status
        var ddlCurr = FindControlRecursive(phFormFields, "ddlCurrentStatus") as DropDownList; if (ddlCurr != null) PopulateCurrentStatusDropdown(ddlCurr);
        // Calibration Frequency
        var ddlCalF = FindControlRecursive(phFormFields, "ddlCalFreq") as DropDownList; if (ddlCalF != null) PopulateCalibrationFrequencyDropdown(ddlCalF);
        // PM Frequency
        var ddlPMF = FindControlRecursive(phFormFields, "ddlPMFreq") as DropDownList; if (ddlPMF != null) PopulatePMFrequencyDropdown(ddlPMF);
        // Device Type
        var ddlDT = FindControlRecursive(phFormFields, "ddlDeviceType") as DropDownList; if (ddlDT != null) PopulateDeviceTypeDropdown(ddlDT);
        // Manufacturer
        var ddlM = FindControlRecursive(phFormFields, "ddlManufacturer") as DropDownList; if (ddlM != null) PopulateManufacturerDropdown(ddlM);
        // ATE (for Asset)
        var ddlAte = FindControlRecursive(phFormFields, "ddlATE") as DropDownList; if (ddlAte != null) PopulateATEDropdown(ddlAte);
        // PM Responsible (Users)
        var msUsers = FindControlRecursive(phFormFields, "msPMResponsible_options") as Panel; if (msUsers != null) PopulateUsersMultiSelectDropdown(msUsers, "msPMResponsible");
        // Swap Capability (Assets)
        var msAssets = FindControlRecursive(phFormFields, "msSwapCapability_options") as Panel; if (msAssets != null) PopulateAssetsMultiSelectDropdown(msAssets, "msSwapCapability");
    }

    // The following population helpers mirror CreateNewItem.aspx.cs minimal implementations
    private string ConnectionString { get { return ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString; } }
    private void PopulateLocationDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT DISTINCT StationSubLineCode FROM TestStation_Bay WHERE StationSubLineCode IS NOT NULL AND StationSubLineCode!='' ORDER BY StationSubLineCode", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var v = r[0].ToString(); ddl.Items.Add(new ListItem(v, v)); } } } } catch { ddl.Items.Add(new ListItem("Error loading locations", "")); }
    }
    private void PopulateCurrentStatusDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("In Use", "In Use"));
        ddl.Items.Add(new ListItem("Spare", "Spare"));
        ddl.Items.Add(new ListItem("Out of Service - Damaged", "Out of Service - Damaged"));
        ddl.Items.Add(new ListItem("Out of Service - Under Repair", "Out of Service - Under Repair"));
        ddl.Items.Add(new ListItem("Out of Service - In Calibration", "Out of Service - In Calibration"));
        ddl.Items.Add(new ListItem("Scraped / Returned to vendor", "Scraped / Returned to vendor"));
    }
    private void PopulateATEStatusDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("In Use", "In Use"));
        ddl.Items.Add(new ListItem("Spare", "Spare"));
        ddl.Items.Add(new ListItem("Out of Service - Damaged", "Out of Service - Damaged"));
        ddl.Items.Add(new ListItem("Out of Service - Under Repair", "Out of Service - Under Repair"));
        ddl.Items.Add(new ListItem("Scraped", "Scraped"));
    }
    private void PopulateDeviceTypeDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT DISTINCT DeviceType FROM Asset_Inventory WHERE DeviceType IS NOT NULL AND DeviceType!='' ORDER BY DeviceType", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var v = r[0].ToString(); ddl.Items.Add(new ListItem(v, v)); } } } } catch { ddl.Items.Add(new ListItem("Equipment", "Equipment")); ddl.Items.Add(new ListItem("Tool", "Tool")); ddl.Items.Add(new ListItem("Instrument", "Instrument")); }
    }
    private void PopulateManufacturerDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT DISTINCT Manufacturer FROM Asset_Inventory WHERE Manufacturer IS NOT NULL AND Manufacturer!='' ORDER BY Manufacturer", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var v = r[0].ToString(); ddl.Items.Add(new ListItem(v, v)); } } } } catch { ddl.Items.Add(new ListItem("Error loading manufacturers", "")); }
    }
    private void PopulateATEDropdown(DropDownList ddl)
    {
        ddl.Items.Clear(); ddl.Items.Add(new ListItem("", ""));
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT ATEInventoryID, ATEName FROM ATE_Inventory WHERE ATEName IS NOT NULL ORDER BY ATEName", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { ddl.Items.Add(new ListItem(r[1].ToString(), r[0].ToString())); } } } } catch { ddl.Items.Add(new ListItem("Error loading ATE items", "")); }
    }
    private void PopulateCalibrationFrequencyDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("Every 6 Months", "Every 6 Months"));
        ddl.Items.Add(new ListItem("Every Year", "Every Year"));
        ddl.Items.Add(new ListItem("Every 2 Years", "Every 2 Years"));
        ddl.Items.Add(new ListItem("Every 5 Years", "Every 5 Years"));
        ddl.Items.Add(new ListItem("N/A", "N/A"));
    }
    private void PopulatePMFrequencyDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("Every Month", "Every Month"));
        ddl.Items.Add(new ListItem("Every 3 Months", "Every 3 Months"));
        ddl.Items.Add(new ListItem("Every 4 Months", "Every 4 Months"));
        ddl.Items.Add(new ListItem("Every 6 Months", "Every 6 Months"));
        ddl.Items.Add(new ListItem("Every Year", "Every Year"));
        ddl.Items.Add(new ListItem("N/A", "N/A"));
    }
    private void PopulateUsersMultiSelectDropdown(Panel container, string baseName)
    {
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT UserID, FullName FROM Users WHERE IsActive=1 ORDER BY FullName", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var row = new Panel { CssClass = "multi-select-option" }; var cb = new CheckBox { ID = baseName + "_" + r[0].ToString() }; cb.Attributes["data-value"] = r[0].ToString(); cb.InputAttributes["aria-label"] = r[1].ToString(); cb.InputAttributes["data-label"] = r[1].ToString(); var txt = new Literal { Text = "<span class='multi-select-option-label'>" + HttpUtility.HtmlEncode(r[1].ToString()) + "</span>" }; row.Controls.Add(cb); row.Controls.Add(txt); container.Controls.Add(row); } } } } catch { var row = new Panel { CssClass = "multi-select-option" }; row.Controls.Add(new Label { Text = "Error loading users" }); container.Controls.Add(row); }
    }
    private void PopulateAssetsMultiSelectDropdown(Panel container, string baseName)
    {
        try { using (var conn = new SqlConnection(ConnectionString)) using (var cmd = new SqlCommand("SELECT AssetInventoryID, ModelNo FROM Asset_Inventory WHERE ModelNo IS NOT NULL ORDER BY ModelNo", conn)) { conn.Open(); using (var r = cmd.ExecuteReader()) { while (r.Read()) { var row = new Panel { CssClass = "multi-select-option" }; var cb = new CheckBox { ID = baseName + "_" + r[0].ToString() }; cb.Attributes["data-value"] = r[0].ToString(); cb.InputAttributes["aria-label"] = r[1].ToString(); cb.InputAttributes["data-label"] = r[1].ToString(); var txt = new Literal { Text = "<span class='multi-select-option-label'>" + HttpUtility.HtmlEncode(r[1].ToString()) + "</span>" }; row.Controls.Add(cb); row.Controls.Add(txt); container.Controls.Add(row); } } } } catch { var row = new Panel { CssClass = "multi-select-option" }; row.Controls.Add(new Label { Text = "Error loading assets" }); container.Controls.Add(row); }
    }

    private void LoadItemData()
    {
        if (string.IsNullOrEmpty(CurrentKey)) return;
        var table = GetTableForType(CurrentType);
        using (var conn = new SqlConnection(ConnectionString))
        using (var cmd = new SqlCommand("SELECT TOP 1 * FROM " + table + " WHERE EatonID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", CurrentKey);
            conn.Open();
            using (var rdr = cmd.ExecuteReader())
            {
                if (!rdr.Read()) { ShowBanner("Item not found.", "error"); return; }
                // Map: handle common, with type-specific branches
                SetText("txtEatonID", SafeGet(rdr, "EatonID"));
                if (CurrentType.Equals("ATE", StringComparison.OrdinalIgnoreCase))
                {
                    SetText("txtATEName", SafeGet(rdr, "ATEName"));
                    SetText("txtATEDescription", SafeGet(rdr, "ATEDescription"));
                    SetDdlText("ddlLocation", SafeGet(rdr, "Location"));
                    SetFolderField("txtATEFolder", SafeGet(rdr, "ATEFolder"));
                    SetDdlText("ddlATEStatus", SafeGet(rdr, "ATEStatus"));
                    SetBool("chkRequiresCalibration", SafeObj(rdr, "RequiresCalibration"));
                    SetText("txtCalEstimatedTime", SafeGet(rdr, "CalibrationEstimatedTime"));
                    SetText("txtCalibrationID", SafeGet(rdr, "CalibrationID"));
                    SetDdlText("ddlCalFreq", SafeGet(rdr, "CalibrationFrequency"));
                    SetText("txtLastCal", SafeGet(rdr, "LastCalibration"));
                    SetText("txtCalBy", SafeGet(rdr, "CalibratedBy"));
                    SetText("txtNextCal", SafeGet(rdr, "NextCalibration"));
                    SetBool("chkRequiredPM", SafeObj(rdr, "RequiredPM"));
                    SetText("txtPMEstimatedTime", SafeGet(rdr, "PMEstimatedTime"));
                    SetDdlText("ddlPMFreq", SafeGet(rdr, "PMFrequency"));
                    SetMultiFromCsv("msPMResponsible", SafeGet(rdr, "PMResponsible"));
                    SetText("txtLastPM", SafeGet(rdr, "LastPM"));
                    SetText("txtLastPMBy", SafeGet(rdr, "LastPMBy"));
                    SetText("txtNextPM", SafeGet(rdr, "NextPM"));
                    SetText("txtComments", SafeGet(rdr, "Comments"));
                    // Initialize existing image preview
                    SetPreviewImage("fuATEImage", SafeGet(rdr, "ATEImage"));
                }
                else if (CurrentType.Equals("Asset", StringComparison.OrdinalIgnoreCase))
                {
                    SetText("txtModelNo", SafeGet(rdr, "ModelNo"));
                    SetText("txtDeviceName", SafeGet(rdr, "DeviceName"));
                    SetText("txtDeviceDescription", SafeGet(rdr, "DeviceDescription"));
                    SetDdlText("ddlATE", SafeGet(rdr, "ATE"), treatAsText: true);
                    SetDdlText("ddlLocation", SafeGet(rdr, "Location"));
                    SetDdlText("ddlDeviceType", SafeGet(rdr, "DeviceType"));
                    SetDdlText("ddlManufacturer", SafeGet(rdr, "Manufacturer"));
                    SetText("txtManufacturerSite", SafeGet(rdr, "ManufacturerSite"));
                    SetFolderField("txtDeviceFolder", SafeGet(rdr, "DeviceFolder"));
                    SetDdlText("ddlCurrentStatus", SafeGet(rdr, "CurrentStatus"));
                    SetBool("chkRequiresCalibration", SafeObj(rdr, "RequiresCalibration"));
                    SetText("txtCalEstimatedTime", SafeGet(rdr, "CalibrationEstimatedTime"));
                    SetText("txtCalibrationID", SafeGet(rdr, "CalibrationID"));
                    SetDdlText("ddlCalFreq", SafeGet(rdr, "CalibrationFrequency"));
                    SetText("txtLastCal", SafeGet(rdr, "LastCalibration"));
                    SetText("txtCalBy", SafeGet(rdr, "CalibratedBy"));
                    SetText("txtNextCal", SafeGet(rdr, "NextCalibration"));
                    SetBool("chkRequiredPM", SafeObj(rdr, "RequiredPM"));
                    SetText("txtPMEstimatedTime", SafeGet(rdr, "PMEstimatedTime"));
                    SetDdlText("ddlPMFreq", SafeGet(rdr, "PMFrequency"));
                    SetMultiFromCsv("msPMResponsible", SafeGet(rdr, "PMResponsible"));
                    SetText("txtLastPM", SafeGet(rdr, "LastPM"));
                    SetText("txtLastPMBy", SafeGet(rdr, "LastPMBy"));
                    SetText("txtNextPM", SafeGet(rdr, "NextPM"));
                    SetMultiFromCsv("msSwapCapability", SafeGet(rdr, "SwapCapability"));
                    SetText("txtComments", SafeGet(rdr, "Comments"));
                    // Initialize existing image preview
                    SetPreviewImage("fuDeviceImage", SafeGet(rdr, "DeviceImage"));
                }
                else if (CurrentType.Equals("Fixture", StringComparison.OrdinalIgnoreCase))
                {
                    SetText("txtFixtureModel", SafeGet(rdr, "FixtureModelNoName"));
                    SetText("txtFixtureDescription", SafeGet(rdr, "FixtureDescription"));
                    SetDdlText("ddlLocation", SafeGet(rdr, "Location"));
                    SetFolderField("txtFixtureFolder", SafeGet(rdr, "FixtureFolder"));
                    SetDdlText("ddlCurrentStatus", SafeGet(rdr, "CurrentStatus"));
                    SetBool("chkRequiresCalibration", SafeObj(rdr, "RequiresCalibration"));
                    SetText("txtCalEstimatedTime", SafeGet(rdr, "CalibrationEstimatedTime"));
                    SetText("txtCalibrationID", SafeGet(rdr, "CalibrationID"));
                    SetDdlText("ddlCalFreq", SafeGet(rdr, "CalibrationFrequency"));
                    SetText("txtLastCal", SafeGet(rdr, "LastCalibration"));
                    SetText("txtCalBy", SafeGet(rdr, "CalibratedBy"));
                    SetText("txtNextCal", SafeGet(rdr, "NextCalibration"));
                    SetBool("chkRequiredPM", SafeObj(rdr, "RequiredPM"));
                    SetText("txtPMEstimatedTime", SafeGet(rdr, "PMEstimatedTime"));
                    SetDdlText("ddlPMFreq", SafeGet(rdr, "PMFrequency"));
                    SetMultiFromCsv("msPMResponsible", SafeGet(rdr, "PMResponsible"));
                    SetText("txtLastPM", SafeGet(rdr, "LastPM"));
                    SetText("txtLastPMBy", SafeGet(rdr, "LastPMBy"));
                    SetText("txtNextPM", SafeGet(rdr, "NextPM"));
                    SetText("txtComments", SafeGet(rdr, "Comments"));
                    // Initialize existing image preview
                    SetPreviewImage("fuFixtureImage", SafeGet(rdr, "FixtureImage"));
                }
                else if (CurrentType.Equals("Harness", StringComparison.OrdinalIgnoreCase))
                {
                    SetText("txtHarnessModel", SafeGet(rdr, "HarnessModelNo"));
                    SetText("txtHarnessDescription", SafeGet(rdr, "HarnessDescription"));
                    SetDdlText("ddlLocation", SafeGet(rdr, "Location"));
                    SetFolderField("txtHarnessFolder", SafeGet(rdr, "FixtureFolder"));
                    SetDdlText("ddlCurrentStatus", SafeGet(rdr, "CurrentStatus"));
                    SetBool("chkRequiresCalibration", SafeObj(rdr, "RequiresCalibration"));
                    SetText("txtCalEstimatedTime", SafeGet(rdr, "CalibrationEstimatedTime"));
                    SetText("txtCalibrationID", SafeGet(rdr, "CalibrationID"));
                    SetDdlText("ddlCalFreq", SafeGet(rdr, "CalibrationFrequency"));
                    SetText("txtLastCal", SafeGet(rdr, "LastCalibration"));
                    SetText("txtCalBy", SafeGet(rdr, "CalibratedBy"));
                    SetText("txtNextCal", SafeGet(rdr, "NextCalibration"));
                    SetBool("chkRequiredPM", SafeObj(rdr, "RequiredPM"));
                    SetText("txtPMEstimatedTime", SafeGet(rdr, "PMEstimatedTime"));
                    SetDdlText("ddlPMFreq", SafeGet(rdr, "PMFrequency"));
                    SetMultiFromCsv("msPMResponsible", SafeGet(rdr, "PMResponsible"));
                    SetText("txtLastPM", SafeGet(rdr, "LastPM"));
                    SetText("txtLastPMBy", SafeGet(rdr, "LastPMBy"));
                    SetText("txtNextPM", SafeGet(rdr, "NextPM"));
                    SetText("txtComments", SafeGet(rdr, "Comments"));
                    // Initialize existing image preview
                    SetPreviewImage("fuHarnessImage", SafeGet(rdr, "FixtureImage"));
                }
            }
        }
    }

    private string SafeGet(SqlDataReader rdr, string col)
    {
        try { int ord = rdr.GetOrdinal(col); if (ord >= 0 && !rdr.IsDBNull(ord)) return rdr.GetValue(ord).ToString(); }
        catch { }
        return string.Empty;
    }
    private object SafeObj(SqlDataReader rdr, string col)
    {
        try { int ord = rdr.GetOrdinal(col); if (ord >= 0) return rdr.IsDBNull(ord) ? null : rdr.GetValue(ord); }
        catch { }
        return null;
    }

    private void SaveItem(string type, string key)
    {
        if (string.IsNullOrEmpty(key)) return;
        if (type.Equals("ATE", StringComparison.OrdinalIgnoreCase)) SaveATE(key);
        else if (type.Equals("Asset", StringComparison.OrdinalIgnoreCase)) SaveAsset(key);
        else if (type.Equals("Fixture", StringComparison.OrdinalIgnoreCase)) SaveFixture(key);
        else if (type.Equals("Harness", StringComparison.OrdinalIgnoreCase)) SaveHarness(key);
    }

    private void SaveATE(string key)
    {
        var current = LoadCurrentRecord("dbo.ATE_Inventory", "EatonID", key);
        string eatonId = GetText("txtEatonID");
        string ateName = GetText("txtATEName");
        string ateDesc = GetText("txtATEDescription");
        string location = GetDdlText("ddlLocation");
        string ateFolder = GetText("txtATEFolder");
        string ateStatus = GetDdlText("ddlATEStatus");
        bool requiresCal = GetBool("chkRequiresCalibration");
        string calEstimatedTime = GetText("txtCalEstimatedTime");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetDdlText("ddlCalFreq");
        bool requiredPM = GetBool("chkRequiredPM");
        string pmEstimatedTime = GetText("txtPMEstimatedTime");
        string pmFreq = GetDdlText("ddlPMFreq");
        string pmResponsible = GetMultiCsvFromControls("msPMResponsible");
        string comments = GetText("txtComments");
        string ateImagePath = SaveUpload("fuATEImage", "Uploads/Images/ATE");
        
        // Auto-create folder if empty (for legacy items created before auto-folder feature)
        string folderPathToSave = ateFolder;
        if (string.IsNullOrWhiteSpace(ateFolder) && !string.IsNullOrWhiteSpace(eatonId))
        {
            try
            {
                bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("ATE", eatonId);
                if (folderCreated)
                {
                    string localPath = LocalFileSystemService.GetEquipmentFolderPath("ATE", eatonId);
                    if (!string.IsNullOrEmpty(localPath))
                    {
                        // Convert to relative path by removing the base storage path (same as CreateNewItem)
                        string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                        string relativePath = localPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                            ? localPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                            : localPath;
                        
                        // Ensure it starts with Storage/ for consistency
                        if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                        }
                        
                        folderPathToSave = relativePath;
                    }
                }
            }
            catch { }
        }
        
        using (var conn = new SqlConnection(ConnectionString))
        using (var cmd = new SqlCommand(@"UPDATE ATE_Inventory SET
            EatonID=@EatonID, ATEName=@ATEName, ATEDescription=@ATEDescription, Location=@Location,
            ATEFolder=@ATEFolder, ATEStatus=@ATEStatus, RequiresCalibration=@RequiresCalibration,
            CalibrationEstimatedTime=@CalEstimatedTime, CalibrationID=@CalibrationID, CalibrationFrequency=@CalibrationFrequency,
            RequiredPM=@RequiredPM, PMEstimatedTime=@PMEstimatedTime, PMFrequency=@PMFrequency, PMResponsible=@PMResponsible,
            Comments=@Comments" + (ateImagePath != null ? ", ATEImage=@ATEImage" : "") + @" WHERE EatonID=@Key", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)eatonId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEName", ateName ?? "");
            cmd.Parameters.AddWithValue("@ATEDescription", (object)NullableStr(ateDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableStr(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEFolder", (object)NullableStr(folderPathToSave) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEStatus", (object)NullableStr(ateStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalEstimatedTime", (object)NullableStr(calEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableStr(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableStr(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMEstimatedTime", (object)NullableStr(pmEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableStr(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableStr(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableStr(comments) ?? DBNull.Value);
            if (ateImagePath != null) cmd.Parameters.AddWithValue("@ATEImage", ateImagePath);
            cmd.Parameters.AddWithValue("@Key", key);
            conn.Open(); cmd.ExecuteNonQuery();

            var recName = GetRecordNameForType("ATE", eatonId, ateName);
            var changes = new List<ChangeLogEntry>();
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "EatonID", current, eatonId);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "ATEName", current, ateName);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "ATEDescription", current, ateDesc);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "Location", current, location);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "ATEFolder", current, folderPathToSave);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "ATEStatus", current, ateStatus);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "RequiresCalibration", current, requiresCal);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "CalibrationID", current, calId);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "CalibrationFrequency", current, calFreq);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "RequiredPM", current, requiredPM);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "PMFrequency", current, pmFreq);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "PMResponsible", current, pmResponsible);
            AddChange(changes, "dbo.ATE_Inventory", key, recName, "Comments", current, comments);
            if (ateImagePath != null) AddChange(changes, "dbo.ATE_Inventory", key, recName, "ATEImage", current, ateImagePath);
            BulkLogChanges(conn, changes);
        }
    }

    private void SaveAsset(string key)
    {
        var current = LoadCurrentRecord("dbo.Asset_Inventory", "EatonID", key);
        string eatonId = GetText("txtEatonID");
        string modelNo = GetText("txtModelNo");
        string deviceName = GetText("txtDeviceName");
        string deviceDesc = GetText("txtDeviceDescription");
        string ate = GetDdlText("ddlATE", treatAsText:true);
        string location = GetDdlText("ddlLocation");
        string deviceType = GetDdlText("ddlDeviceType");
        string manufacturer = GetDdlText("ddlManufacturer");
        string manufacturerSite = GetText("txtManufacturerSite");
        string deviceFolder = GetText("txtDeviceFolder");
        string currentStatus = GetDdlText("ddlCurrentStatus");
        bool requiresCal = GetBool("chkRequiresCalibration");
        string calEstimatedTime = GetText("txtCalEstimatedTime");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetDdlText("ddlCalFreq");
        bool requiredPM = GetBool("chkRequiredPM");
        string pmEstimatedTime = GetText("txtPMEstimatedTime");
        string pmFreq = GetDdlText("ddlPMFreq");
        string pmResponsible = GetMultiCsvFromControls("msPMResponsible");
        string swapCapability = GetMultiCsvFromControls("msSwapCapability");
        string comments = GetText("txtComments");
        string deviceImagePath = SaveUpload("fuDeviceImage", "Uploads/Images/Assets");
        
        // Auto-create folder if empty (for legacy items created before auto-folder feature)
        string folderPathToSave = deviceFolder;
        if (string.IsNullOrWhiteSpace(deviceFolder) && !string.IsNullOrWhiteSpace(eatonId))
        {
            try
            {
                bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Asset", eatonId);
                if (folderCreated)
                {
                    string localPath = LocalFileSystemService.GetEquipmentFolderPath("Asset", eatonId);
                    if (!string.IsNullOrEmpty(localPath))
                    {
                        // Convert to relative path by removing the base storage path (same as CreateNewItem)
                        string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                        string relativePath = localPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                            ? localPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                            : localPath;
                        
                        // Ensure it starts with Storage/ for consistency
                        if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                        }
                        
                        folderPathToSave = relativePath;
                    }
                }
            }
            catch { }
        }
        
        using (var conn = new SqlConnection(ConnectionString))
        using (var cmd = new SqlCommand(@"UPDATE Asset_Inventory SET
            EatonID=@EatonID, ModelNo=@ModelNo, DeviceName=@DeviceName, DeviceDescription=@DeviceDescription,
            ATE=@ATE, Location=@Location, DeviceType=@DeviceType, Manufacturer=@Manufacturer, ManufacturerSite=@ManufacturerSite,
            DeviceFolder=@DeviceFolder, CurrentStatus=@CurrentStatus, RequiresCalibration=@RequiresCalibration,
            CalibrationEstimatedTime=@CalEstimatedTime, CalibrationID=@CalibrationID, CalibrationFrequency=@CalibrationFrequency,
            RequiredPM=@RequiredPM, PMEstimatedTime=@PMEstimatedTime, PMFrequency=@PMFrequency, PMResponsible=@PMResponsible,
            SwapCapability=@SwapCapability, Comments=@Comments" + (deviceImagePath != null ? ", DeviceImage=@DeviceImage" : "") + @" WHERE EatonID=@Key", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)eatonId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@ModelNo", (object)NullableStr(modelNo) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceName", deviceName ?? "");
            cmd.Parameters.AddWithValue("@DeviceDescription", (object)NullableStr(deviceDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATE", (object)NullableStr(ate) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableStr(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceType", (object)NullableStr(deviceType) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Manufacturer", (object)NullableStr(manufacturer) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ManufacturerSite", (object)NullableStr(manufacturerSite) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceFolder", (object)NullableStr(folderPathToSave) ?? DBNull.Value);
            if (deviceImagePath != null) cmd.Parameters.AddWithValue("@DeviceImage", deviceImagePath);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableStr(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalEstimatedTime", (object)NullableStr(calEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableStr(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableStr(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMEstimatedTime", (object)NullableStr(pmEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableStr(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableStr(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@SwapCapability", (object)NullableStr(swapCapability) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableStr(comments) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Key", key);
            conn.Open(); cmd.ExecuteNonQuery();

            var recName = GetRecordNameForType("Asset", eatonId, deviceName);
            var changes = new List<ChangeLogEntry>();
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "EatonID", current, eatonId);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "ModelNo", current, modelNo);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "DeviceName", current, deviceName);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "DeviceDescription", current, deviceDesc);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "ATE", current, ate);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "Location", current, location);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "DeviceType", current, deviceType);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "Manufacturer", current, manufacturer);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "ManufacturerSite", current, manufacturerSite);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "DeviceFolder", current, folderPathToSave);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "CurrentStatus", current, currentStatus);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "RequiresCalibration", current, requiresCal);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "CalibrationID", current, calId);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "CalibrationFrequency", current, calFreq);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "RequiredPM", current, requiredPM);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "PMFrequency", current, pmFreq);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "PMResponsible", current, pmResponsible);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "SwapCapability", current, swapCapability);
            AddChange(changes, "dbo.Asset_Inventory", key, recName, "Comments", current, comments);
            if (deviceImagePath != null) AddChange(changes, "dbo.Asset_Inventory", key, recName, "DeviceImage", current, deviceImagePath);
            BulkLogChanges(conn, changes);
        }
    }

    private void SaveFixture(string key)
    {
        var current = LoadCurrentRecord("dbo.Fixture_Inventory", "EatonID", key);
        string eatonId = GetText("txtEatonID");
        string modelNo = GetText("txtFixtureModel");
        string fixtureDesc = GetText("txtFixtureDescription");
        string location = GetDdlText("ddlLocation");
        string fixtureFolder = GetText("txtFixtureFolder");
        string currentStatus = GetDdlText("ddlCurrentStatus");
        bool requiresCal = GetBool("chkRequiresCalibration");
        string calEstimatedTime = GetText("txtCalEstimatedTime");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetDdlText("ddlCalFreq");
        bool requiredPM = GetBool("chkRequiredPM");
        string pmEstimatedTime = GetText("txtPMEstimatedTime");
        string pmFreq = GetDdlText("ddlPMFreq");
        string pmResponsible = GetMultiCsvFromControls("msPMResponsible");
        string comments = GetText("txtComments");
        string fixtureImagePath = SaveUpload("fuFixtureImage", "Uploads/Images/Fixtures");
        
        // Auto-create folder if empty (for legacy items created before auto-folder feature)
        string folderPathToSave = fixtureFolder;
        if (string.IsNullOrWhiteSpace(fixtureFolder) && !string.IsNullOrWhiteSpace(eatonId))
        {
            try
            {
                bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Fixture", eatonId);
                if (folderCreated)
                {
                    string localPath = LocalFileSystemService.GetEquipmentFolderPath("Fixture", eatonId);
                    if (!string.IsNullOrEmpty(localPath))
                    {
                        // Convert to relative path by removing the base storage path (same as CreateNewItem)
                        string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                        string relativePath = localPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                            ? localPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                            : localPath;
                        
                        // Ensure it starts with Storage/ for consistency
                        if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                        }
                        
                        folderPathToSave = relativePath;
                    }
                }
            }
            catch { }
        }
        
        using (var conn = new SqlConnection(ConnectionString))
        using (var cmd = new SqlCommand(@"UPDATE Fixture_Inventory SET
            EatonID=@EatonID, FixtureModelNoName=@FixtureModelNoName, FixtureDescription=@FixtureDescription,
            Location=@Location, FixtureFolder=@FixtureFolder, CurrentStatus=@CurrentStatus,
            RequiresCalibration=@RequiresCalibration, CalibrationEstimatedTime=@CalEstimatedTime, CalibrationID=@CalibrationID, CalibrationFrequency=@CalibrationFrequency,
            RequiredPM=@RequiredPM, PMEstimatedTime=@PMEstimatedTime, PMFrequency=@PMFrequency, PMResponsible=@PMResponsible, Comments=@Comments" + (fixtureImagePath != null ? ", FixtureImage=@FixtureImage" : "") + @" WHERE EatonID=@Key", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)eatonId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureModelNoName", modelNo ?? "");
            cmd.Parameters.AddWithValue("@FixtureDescription", (object)NullableStr(fixtureDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableStr(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureFolder", (object)NullableStr(folderPathToSave) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableStr(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalEstimatedTime", (object)NullableStr(calEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableStr(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableStr(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMEstimatedTime", (object)NullableStr(pmEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableStr(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableStr(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableStr(comments) ?? DBNull.Value);
            if (fixtureImagePath != null) cmd.Parameters.AddWithValue("@FixtureImage", fixtureImagePath);
            cmd.Parameters.AddWithValue("@Key", key);
            conn.Open(); cmd.ExecuteNonQuery();

            var recName = GetRecordNameForType("Fixture", eatonId, null, modelNo);
            var changes = new List<ChangeLogEntry>();
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "EatonID", current, eatonId);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "FixtureModelNoName", current, modelNo);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "FixtureDescription", current, fixtureDesc);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "Location", current, location);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "FixtureFolder", current, folderPathToSave);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "CurrentStatus", current, currentStatus);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "RequiresCalibration", current, requiresCal);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "CalibrationID", current, calId);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "CalibrationFrequency", current, calFreq);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "RequiredPM", current, requiredPM);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "PMFrequency", current, pmFreq);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "PMResponsible", current, pmResponsible);
            AddChange(changes, "dbo.Fixture_Inventory", key, recName, "Comments", current, comments);
            if (fixtureImagePath != null) AddChange(changes, "dbo.Fixture_Inventory", key, recName, "FixtureImage", current, fixtureImagePath);
            BulkLogChanges(conn, changes);
        }
    }

    private void SaveHarness(string key)
    {
        var current = LoadCurrentRecord("dbo.Harness_Inventory", "EatonID", key);
        string eatonId = GetText("txtEatonID");
        string modelNo = GetText("txtHarnessModel");
        string harnessDesc = GetText("txtHarnessDescription");
        string location = GetDdlText("ddlLocation");
        string fixtureFolder = GetText("txtHarnessFolder");
        string currentStatus = GetDdlText("ddlCurrentStatus");
        bool requiresCal = GetBool("chkRequiresCalibration");
        string calEstimatedTime = GetText("txtCalEstimatedTime");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetDdlText("ddlCalFreq");
        bool requiredPM = GetBool("chkRequiredPM");
        string pmEstimatedTime = GetText("txtPMEstimatedTime");
        string pmFreq = GetDdlText("ddlPMFreq");
        string pmResponsible = GetMultiCsvFromControls("msPMResponsible");
        string comments = GetText("txtComments");
        string fixtureImagePath = SaveUpload("fuHarnessImage", "Uploads/Images/Harnesses");
        
        // Auto-create folder if empty (for legacy items created before auto-folder feature)
        string folderPathToSave = fixtureFolder;
        if (string.IsNullOrWhiteSpace(fixtureFolder) && !string.IsNullOrWhiteSpace(eatonId))
        {
            try
            {
                bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Harness", eatonId);
                if (folderCreated)
                {
                    string localPath = LocalFileSystemService.GetEquipmentFolderPath("Harness", eatonId);
                    if (!string.IsNullOrEmpty(localPath))
                    {
                        // Convert to relative path by removing the base storage path (same as CreateNewItem)
                        string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                        string relativePath = localPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                            ? localPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                            : localPath;
                        
                        // Ensure it starts with Storage/ for consistency
                        if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                        {
                            relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                        }
                        
                        folderPathToSave = relativePath;
                    }
                }
            }
            catch { }
        }
        
        using (var conn = new SqlConnection(ConnectionString))
        using (var cmd = new SqlCommand(@"UPDATE Harness_Inventory SET
            EatonID=@EatonID, HarnessModelNo=@HarnessModelNo, HarnessDescription=@HarnessDescription,
            Location=@Location, FixtureFolder=@FixtureFolder, CurrentStatus=@CurrentStatus,
            RequiresCalibration=@RequiresCalibration, CalibrationEstimatedTime=@CalEstimatedTime, CalibrationID=@CalibrationID, CalibrationFrequency=@CalibrationFrequency,
            RequiredPM=@RequiredPM, PMEstimatedTime=@PMEstimatedTime, PMFrequency=@PMFrequency, PMResponsible=@PMResponsible, Comments=@Comments" + (fixtureImagePath != null ? ", FixtureImage=@FixtureImage" : "") + @" WHERE EatonID=@Key", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)eatonId ?? (object)DBNull.Value);
            cmd.Parameters.AddWithValue("@HarnessModelNo", modelNo ?? "");
            cmd.Parameters.AddWithValue("@HarnessDescription", (object)NullableStr(harnessDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableStr(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureFolder", (object)NullableStr(folderPathToSave) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableStr(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalEstimatedTime", (object)NullableStr(calEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableStr(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableStr(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMEstimatedTime", (object)NullableStr(pmEstimatedTime) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableStr(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableStr(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableStr(comments) ?? DBNull.Value);
            if (fixtureImagePath != null) cmd.Parameters.AddWithValue("@FixtureImage", fixtureImagePath);
            cmd.Parameters.AddWithValue("@Key", key);
            conn.Open(); cmd.ExecuteNonQuery();

            var recName = GetRecordNameForType("Harness", eatonId, null, modelNo);
            var changes = new List<ChangeLogEntry>();
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "EatonID", current, eatonId);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "HarnessModelNo", current, modelNo);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "HarnessDescription", current, harnessDesc);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "Location", current, location);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "FixtureFolder", current, folderPathToSave);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "CurrentStatus", current, currentStatus);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "RequiresCalibration", current, requiresCal);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "CalibrationID", current, calId);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "CalibrationFrequency", current, calFreq);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "RequiredPM", current, requiredPM);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "PMFrequency", current, pmFreq);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "PMResponsible", current, pmResponsible);
            AddChange(changes, "dbo.Harness_Inventory", key, recName, "Comments", current, comments);
            if (fixtureImagePath != null) AddChange(changes, "dbo.Harness_Inventory", key, recName, "FixtureImage", current, fixtureImagePath);
            BulkLogChanges(conn, changes);
        }
    }

    // --- Mini helpers for binding ---
    private void SetText(string id, string value) { var tb = FindControlRecursive(phFormFields, id) as TextBox; if (tb != null) tb.Text = value ?? string.Empty; }
    
    private void SetFolderField(string id, string folderPath)
    {
        // Convert local path to network path if needed
        string displayPath = folderPath;
        if (!string.IsNullOrEmpty(folderPath))
        {
            // If it's a relative path (starts with Storage/), convert to full network path
            if (folderPath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
            {
                string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
                displayPath = string.Format("\\\\{0}\\Test Engineering Dashboard\\{1}", serverName, folderPath);
            }
            else
            {
                // It's already a full path, use ConvertToNetworkPath for any other conversions
                displayPath = LocalFileSystemService.ConvertToNetworkPath(folderPath);
            }
        }
        
        // Set the hidden textbox value (original path)
        var tb = FindControlRecursive(phFormFields, id) as TextBox;
        if (tb != null) tb.Text = folderPath ?? string.Empty;
        
        // Set the visible clickable link (network path)
        var linkDiv = FindControlRecursive(phFormFields, id + "_link") as Panel;
        if (linkDiv != null && !string.IsNullOrEmpty(displayPath))
        {
            // Convert network path to HTTP URL format
            // \\servername\share\path -> http://servername/share/path
            string serverName = ConfigurationManager.AppSettings["ServerName"] ?? "localhost";
            string httpPath = displayPath.Replace("\\\\" + serverName + "\\", "http://" + serverName + "/").Replace("\\", "/");
            
            // Create a simple clickable link
            var linkHtml = "<a href=\"" + HttpUtility.HtmlAttributeEncode(httpPath) + "\" " +
                          "target=\"_blank\" " +
                          "style=\"color:#4a9eff; text-decoration:none; font-size:13px; word-break:break-all; display:block;\" " +
                          "title=\"Click to open: " + HttpUtility.HtmlAttributeEncode(httpPath) + "\">" +
                          HttpUtility.HtmlEncode(displayPath) +
                          "</a>";
            linkDiv.Controls.Clear();
            linkDiv.Controls.Add(new Literal { Text = linkHtml });
        }
        else if (linkDiv != null)
        {
            linkDiv.Controls.Clear();
            linkDiv.Controls.Add(new Literal { Text = "<span style=\"color:#999; font-style:italic; font-size:13px;\">No folder path</span>" });
        }
    }
    
    private string GetText(string id) { var tb = FindControlRecursive(phFormFields, id) as TextBox; return tb != null ? tb.Text.Trim() : null; }
    private void SetDdlText(string id, string value, bool treatAsText=false)
    {
        var ddl = FindControlRecursive(phFormFields, id) as DropDownList; if (ddl == null) return;
        var val = value ?? string.Empty;
        if (treatAsText)
        {
            var byText = ddl.Items.Cast<ListItem>().FirstOrDefault(li => string.Equals(li.Text, val, StringComparison.OrdinalIgnoreCase));
            if (byText != null)
            {
                ddl.ClearSelection(); byText.Selected = true; return;
            }
            // not found, add and select
            var newItem = new ListItem(val, val); ddl.Items.Insert(0, newItem); ddl.ClearSelection(); newItem.Selected = true; return;
        }
        // Default: try by value, fallback by text, then add
        var byValue = ddl.Items.FindByValue(val) ?? ddl.Items.FindByText(val);
        if (byValue != null)
        {
            ddl.ClearSelection(); byValue.Selected = true; return;
        }
        var liNew = new ListItem(val, val); ddl.Items.Insert(0, liNew); ddl.ClearSelection(); liNew.Selected = true;
    }
    private string GetDdlText(string id, bool treatAsText=false) { var ddl = FindControlRecursive(phFormFields, id) as DropDownList; return ddl != null ? (treatAsText ? ddl.SelectedItem.Text : ddl.SelectedItem.Text) : null; }
    private void SetBool(string id, object dbVal) { var cb = FindControlRecursive(phFormFields, id) as CheckBox; if (cb != null) { bool b=false; if (dbVal!=DBNull.Value) bool.TryParse(dbVal.ToString(), out b); cb.Checked = b; } }
    private bool GetBool(string id) { var cb = FindControlRecursive(phFormFields, id) as CheckBox; return cb != null && cb.Checked; }
    private void SetMultiFromCsv(string baseName, string csv)
    {
        var opts = FindControlRecursive(phFormFields, baseName + "_options") as Panel; 
        if (opts == null) return;
        
        // First, uncheck all checkboxes
        foreach(Control c in opts.Controls) 
        { 
            var cb = c as CheckBox; 
            if (cb == null) { cb = FindChildCheckbox(c); } 
            if (cb != null) { cb.Checked = false; }
        }
        
        // Then, if we have values to set, check the matching ones
        if (string.IsNullOrWhiteSpace(csv)) return;
        
        var want = csv.Split(new[]{','}, StringSplitOptions.RemoveEmptyEntries).Select(s => s.Trim()).ToArray();
        foreach(Control c in opts.Controls) 
        { 
            var cb = c as CheckBox; 
            if (cb == null) { cb = FindChildCheckbox(c); } 
            if (cb != null) 
            { 
                var label = cb.InputAttributes["data-label"]; 
                if (!string.IsNullOrEmpty(label) && want.Contains(label)) 
                    cb.Checked = true; 
            } 
        }
    }
    private string GetMultiCsvFromControls(string baseName)
    { var opts = FindControlRecursive(phFormFields, baseName + "_options") as Panel; if (opts==null) return null; var labels = new System.Collections.Generic.List<string>(); foreach(Control c in opts.Controls){ var cb = c as CheckBox; if (cb==null) cb = FindChildCheckbox(c); if (cb!=null && cb.Checked){ var label = cb.InputAttributes["data-label"]; if (!string.IsNullOrEmpty(label)) labels.Add(label); } } return labels.Count>0 ? string.Join(", ", labels.ToArray()) : null; }
    private CheckBox FindChildCheckbox(Control root){ if (root is CheckBox) return (CheckBox)root; foreach(Control c in root.Controls){ var f = FindChildCheckbox(c); if (f!=null) return f; } return null; }
    private string NullableStr(string v){ return string.IsNullOrWhiteSpace(v) ? null : v; }

    private string SaveUpload(string fileUploadId, string relativeFolder)
    {
        var fu = FindControlRecursive(phFormFields, fileUploadId) as FileUpload;
        if (fu == null || !fu.HasFile) return null;

        try
        {
            // Build physical folder path under app root
            string folder = Server.MapPath("~/") + relativeFolder.Replace("\\", "/").Trim('/');
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            string ext = Path.GetExtension(fu.FileName);
            string safeName = Path.GetFileNameWithoutExtension(fu.FileName).Replace(" ", "_");
            string fileName = DateTime.Now.ToString("yyyyMMddHHmmssfff") + "_" + safeName + ext;
            string fullPath = Path.Combine(folder, fileName);
            fu.SaveAs(fullPath);

            // Return relative path for storage (consistent with folder paths)
            return relativeFolder.Trim('/').Replace("\\", "/") + "/" + fileName;
        }
        catch
        {
            return null;
        }
    }

    private void DeleteItem(string type, string key)
    {
        var table = GetTableForType(type);
        var keyCol = GetKeyColumnForType(type);
        using (var conn = new SqlConnection(ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString))
        using (var cmd = new SqlCommand(string.Format("DELETE FROM {0} WHERE [{1}]=@key", table, keyCol), conn))
        {
            // Log delete before executing
            try
            {
                var rec = LoadCurrentRecord(table, keyCol, key);
                var name = GetRecordNameForType(type, key,
                    rec.ContainsKey("ATEName") ? rec["ATEName"] as string :
                    (rec.ContainsKey("DeviceName") ? rec["DeviceName"] as string : null),
                    rec.ContainsKey("ModelNo") ? rec["ModelNo"] as string :
                    (rec.ContainsKey("FixtureModelNoName") ? rec["FixtureModelNoName"] as string :
                     (rec.ContainsKey("HarnessModelNo") ? rec["HarnessModelNo"] as string : null))
                );
                LogChange(conn, new ChangeLogEntry
                {
                    TableName = table,
                    RecordID = key,
                    RecordName = name,
                    ChangedBy = Session["TED:FullName"] as string ?? Context.User.Identity.Name ?? "Unknown",
                    FieldName = "Record Deleted",
                    OldValue = name,
                    NewValue = string.Empty,
                    ChangeType = "Deleted"
                });
            }
            catch { }
            cmd.Parameters.AddWithValue("@key", key);
            // Check connection state before opening - LogChange may have already opened it
            if (conn.State != ConnectionState.Open) conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    // --- Change log utilities ---
    private class ChangeLogEntry
    {
        public string TableName { get; set; }
        public string RecordID { get; set; }
        public string RecordName { get; set; }
        public string ChangedBy { get; set; }
        public string FieldName { get; set; }
        public string OldValue { get; set; }
        public string NewValue { get; set; }
        public string ChangeType { get; set; }
    }

    private Dictionary<string, object> LoadCurrentRecord(string table, string keyCol, string key)
    {
        var map = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);
        try
        {
            using (var conn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(string.Format("SELECT TOP 1 * FROM {0} WHERE [{1}]=@k", table, keyCol), conn))
            {
                cmd.Parameters.AddWithValue("@k", key);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        for (int i = 0; i < rdr.FieldCount; i++)
                        {
                            map[rdr.GetName(i)] = rdr.IsDBNull(i) ? null : rdr.GetValue(i);
                        }
                    }
                }
            }
        }
        catch { }
        return map;
    }

    private void AddChange(List<ChangeLogEntry> list, string table, string id, string recName, string field, Dictionary<string, object> current, object newVal)
    {
        try
        {
            object oldVal = null; current.TryGetValue(field, out oldVal);
            var oldStr = oldVal == null ? string.Empty : oldVal.ToString();
            var newStr = newVal == null ? string.Empty : newVal.ToString();
            if (string.Equals(oldStr, newStr, StringComparison.Ordinal)) return;
            list.Add(new ChangeLogEntry
            {
                TableName = table,
                RecordID = id,
                RecordName = recName,
                ChangedBy = Session["TED:FullName"] as string ?? Context.User.Identity.Name ?? "Unknown",
                FieldName = field,
                OldValue = oldStr,
                NewValue = newStr,
                ChangeType = "Modified"
            });
        }
        catch { }
    }

    private void BulkLogChanges(SqlConnection conn, List<ChangeLogEntry> changes)
    {
        if (changes == null || changes.Count == 0) return;
        foreach (var c in changes) LogChange(conn, c);
    }

    private void LogChange(SqlConnection conn, ChangeLogEntry entry)
    {
        try
        {
            using (var cmd = new SqlCommand(@"
                INSERT INTO Change_Log (TableName, RecordID, RecordName, ChangedBy, ChangeDate, FieldName, OldValue, NewValue, ChangeType, CreatedDate)
                VALUES (@TableName, @RecordID, @RecordName, @ChangedBy, @ChangeDate, @FieldName, @OldValue, @NewValue, @ChangeType, @CreatedDate)", conn))
            {
                if (conn.State != ConnectionState.Open) conn.Open();
                cmd.Parameters.AddWithValue("@TableName", entry.TableName ?? string.Empty);
                // Ensure RecordID is INT per schema; resolve numeric ID when EatonID is provided
                int recIdInt;
                if (!int.TryParse(entry.RecordID ?? string.Empty, out recIdInt))
                {
                    recIdInt = ResolveNumericId(entry.TableName, entry.RecordID);
                }
                cmd.Parameters.AddWithValue("@RecordID", recIdInt);
                cmd.Parameters.AddWithValue("@RecordName", entry.RecordName ?? string.Empty);
                cmd.Parameters.AddWithValue("@ChangedBy", entry.ChangedBy ?? string.Empty);
                cmd.Parameters.AddWithValue("@ChangeDate", DateTime.Now);
                cmd.Parameters.AddWithValue("@FieldName", entry.FieldName ?? string.Empty);
                cmd.Parameters.AddWithValue("@OldValue", entry.OldValue ?? string.Empty);
                cmd.Parameters.AddWithValue("@NewValue", entry.NewValue ?? string.Empty);
                // Map 'New' -> 'Created' to satisfy CHECK constraint
                var ct = (entry.ChangeType ?? string.Empty);
                if (string.Equals(ct, "New", StringComparison.OrdinalIgnoreCase)) ct = "Created";
                cmd.Parameters.AddWithValue("@ChangeType", ct);
                cmd.Parameters.AddWithValue("@CreatedDate", DateTime.Now);
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private int ResolveNumericId(string tableName, string eatonId)
    {
        if (string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(eatonId)) return 0;
        var t = tableName.Trim();
        string idCol = null;
        if (t.IndexOf("ATE_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "ATEInventoryID";
        else if (t.IndexOf("Asset_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "AssetID"; // fallback to AssetInventoryID if needed
        else if (t.IndexOf("Fixture_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "FixtureID";
        else if (t.IndexOf("Harness_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "HarnessID";
        try
        {
            using (var conn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                if (idCol == "AssetID")
                {
                    cmd.CommandText = "SELECT TOP 1 AssetID FROM " + tableName + " WHERE EatonID=@id";
                }
                else
                {
                    cmd.CommandText = "SELECT TOP 1 " + (idCol ?? "") + " FROM " + tableName + " WHERE EatonID=@id";
                }
                cmd.Parameters.AddWithValue("@id", eatonId);
                conn.Open();
                var o = cmd.ExecuteScalar();
                if (o != null && o != DBNull.Value)
                {
                    int v; if (int.TryParse(o.ToString(), out v)) return v;
                }
                // Asset: try alternate column if first failed
                if (t.IndexOf("Asset_Inventory", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    cmd.Parameters.Clear();
                    cmd.CommandText = "SELECT TOP 1 AssetInventoryID FROM " + tableName + " WHERE EatonID=@id";
                    cmd.Parameters.AddWithValue("@id", eatonId);
                    var o2 = cmd.ExecuteScalar();
                    if (o2 != null && o2 != DBNull.Value)
                    {
                        int v2; if (int.TryParse(o2.ToString(), out v2)) return v2;
                    }
                }
            }
        }
        catch { }
        return 0;
    }

    private string GetRecordNameForType(string type, string eatonId, string nameOrAte, string altModel = null)
    {
        try
        {
            switch ((type ?? "ATE").ToUpperInvariant())
            {
                case "ATE": return !string.IsNullOrWhiteSpace(nameOrAte) ? nameOrAte : (eatonId ?? "ATE Record");
                case "ASSET": return !string.IsNullOrWhiteSpace(nameOrAte) ? nameOrAte : (!string.IsNullOrWhiteSpace(altModel) ? altModel : (eatonId ?? "Asset Record"));
                case "FIXTURE": return !string.IsNullOrWhiteSpace(altModel) ? altModel : (eatonId ?? "Fixture Record");
                case "HARNESS": return !string.IsNullOrWhiteSpace(altModel) ? altModel : (eatonId ?? "Harness Record");
                default: return eatonId ?? "Record";
            }
        }
        catch { return eatonId ?? "Record"; }
    }

    private string GetSelectIdsQuery(string type)
    {
        var table = GetTableForType(type);
        return "SELECT EatonID FROM " + table + " WHERE EatonID IS NOT NULL AND LEN(EatonID)>0 ORDER BY EatonID";
    }

    private string GetSelectIdsWithNameQuery(string type)
    {
        // Return EatonID + best-effort name column for the dropdown text, sorted by ID DESC (newest first)
        if (string.Equals(type, "ATE", StringComparison.OrdinalIgnoreCase))
            return "SELECT EatonID, ATEName FROM dbo.ATE_Inventory WHERE EatonID IS NOT NULL AND LEN(EatonID)>0 ORDER BY ATEInventoryID DESC";
        if (string.Equals(type, "Asset", StringComparison.OrdinalIgnoreCase))
            return "SELECT EatonID, (COALESCE(ModelNo,'')) + CASE WHEN COALESCE(Location,'')<>'' THEN ' / ' + Location ELSE '' END AS Label FROM dbo.Asset_Inventory WHERE EatonID IS NOT NULL AND LEN(EatonID)>0 ORDER BY AssetID DESC";
        if (string.Equals(type, "Fixture", StringComparison.OrdinalIgnoreCase))
            return "SELECT EatonID, FixtureModelNoName FROM dbo.Fixture_Inventory WHERE EatonID IS NOT NULL AND LEN(EatonID)>0 ORDER BY FixtureID DESC";
        if (string.Equals(type, "Harness", StringComparison.OrdinalIgnoreCase))
            return "SELECT EatonID, HarnessModelNo FROM dbo.Harness_Inventory WHERE EatonID IS NOT NULL AND LEN(EatonID)>0 ORDER BY HarnessID DESC";
        return GetSelectIdsQuery(type);
    }

    private string GetTableForType(string type)
    {
        if (string.Equals(type, "ATE", StringComparison.OrdinalIgnoreCase)) return "dbo.ATE_Inventory";
        if (string.Equals(type, "Asset", StringComparison.OrdinalIgnoreCase)) return "dbo.Asset_Inventory";
        if (string.Equals(type, "Fixture", StringComparison.OrdinalIgnoreCase)) return "dbo.Fixture_Inventory";
        if (string.Equals(type, "Harness", StringComparison.OrdinalIgnoreCase)) return "dbo.Harness_Inventory";
        return "dbo.ATE_Inventory";
    }

    private string GetKeyColumnForType(string type)
    {
        return "EatonID";
    }

    private void DisableInputs(Control container)
    {
        foreach (Control c in container.Controls)
        {
            // Text inputs and textareas
            var tb = c as TextBox; if (tb != null) { tb.Enabled = false; }
            // Dropdowns
            var ddl = c as DropDownList; if (ddl != null) { ddl.Enabled = false; }
            // Checkboxes (toggles)
            var cb = c as CheckBox; if (cb != null) { cb.Enabled = false; }
            // File upload inputs
            var fu = c as FileUpload; if (fu != null) { fu.Enabled = false; }
            // Image delete link buttons inside pickers
            var lb = c as LinkButton; if (lb != null)
            {
                var id = lb.ID ?? string.Empty;
                var cls = lb.CssClass ?? string.Empty;
                if (id.EndsWith("_delete", StringComparison.OrdinalIgnoreCase) || cls.IndexOf("image-delete-btn", StringComparison.OrdinalIgnoreCase) >= 0)
                {
                    lb.Visible = false; // hide delete action for non-privileged
                }
            }
            // Multi-select open buttons are Panels with id suffix _button; disable pointer events
            var pnl = c as Panel; if (pnl != null)
            {
                var id = pnl.ID ?? string.Empty;
                if (id.EndsWith("_button", StringComparison.OrdinalIgnoreCase))
                {
                    var style = pnl.Attributes["style"] ?? string.Empty;
                    if (style.IndexOf("pointer-events", StringComparison.OrdinalIgnoreCase) < 0)
                    {
                        pnl.Attributes["style"] = (style + ";pointer-events:none;opacity:.7;").Trim(';');
                    }
                    pnl.Attributes["aria-disabled"] = "true";
                }
            }
            if (c.HasControls()) DisableInputs(c);
        }
    }

    private void ShowBanner(string msg, string type)
    {
        var css = string.IsNullOrEmpty(type) ? "msg-banner" : ("msg-banner " + type);
        var html = "<div class='" + css + "'>" + HttpUtility.HtmlEncode(msg) + "<button class='close' onclick=\"this.parentNode.remove();\">&#x2715;</button></div>" +
                   "<script>setTimeout(function(){var el=document.querySelector('.msg-banner'); if(el) el.remove();}, 3500);</script>";
        phMessage.Controls.Clear();
        phMessage.Controls.Add(new Literal { Text = html });
    }

    // --- Control factories ---
    private Control CreateText(string id, string label, bool readOnly)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var tb = new TextBox { ID = id, CssClass = "" };
        
        // For Eaton ID field, use Enabled = false instead of ReadOnly for proper styling
        if (id == "txtEatonID")
        {
            tb.Enabled = false;
        }
        else
        {
            tb.ReadOnly = readOnly;
        }
        
        wrap.Controls.Add(tb);
        return wrap;
    }

    private Control CreateTextArea(string id, string label)
    {
        var wrap = new Panel { CssClass = "form-group span-8" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var tb = new TextBox { ID = id, TextMode = TextBoxMode.MultiLine };
        wrap.Controls.Add(tb);
        return wrap;
    }

    private Control CreateDropdown(string id, string label, bool readOnly = false)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var ddl = new DropDownList { ID = id };
        
        // Apply disabled styling for read-only fields (gray background)
        if (readOnly)
        {
            ddl.Enabled = false;
        }
        
        wrap.Controls.Add(ddl);
        return wrap;
    }

    private Control CreateUrl(string id, string label, bool readOnly = false)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        
        // For folder fields, create a special container that can show both textbox and link
        bool isFolderField = id.Contains("Folder");
        
        if (isFolderField && readOnly)
        {
            // Create a hidden textbox for the folder path value
            var tb = new TextBox { ID = id, CssClass = "folder-path-hidden" };
            tb.Style.Add("display", "none");
            wrap.Controls.Add(tb);
            
            // Create a div that will show the clickable folder link
            var linkDiv = new Panel { ID = id + "_link", CssClass = "folder-link-display" };
            linkDiv.Style.Add("padding", "10px 12px");
            linkDiv.Style.Add("background", "rgba(0,0,0,0.03)");
            linkDiv.Style.Add("border", "1px solid rgba(0,0,0,0.15)");
            linkDiv.Style.Add("border-radius", "8px");
            linkDiv.Style.Add("min-height", "20px");
            linkDiv.Style.Add("display", "block");
            linkDiv.Style.Add("font-size", "13px");
            linkDiv.Style.Add("word-wrap", "break-word");
            linkDiv.Style.Add("overflow-wrap", "break-word");
            wrap.Controls.Add(linkDiv);
        }
        else
        {
            var tb = new TextBox { ID = id };
            
            // Apply disabled styling for read-only fields (gray background like Eaton ID)
            if (readOnly)
            {
                tb.Enabled = false;
            }
            
            wrap.Controls.Add(tb);
        }
        
        return wrap;
    }

    private Control CreateFile(string id, string label)
    {
        var wrap = new Panel { CssClass = "form-group span-4 img-picker" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        // image preview element
        var img = new System.Web.UI.WebControls.Image { ID = id + "_preview", CssClass = "image-preview", Visible = false, AlternateText = label + " preview" };
        wrap.Controls.Add(img);
        // delete image button (X)
    var del = new LinkButton { ID = id + "_delete", Text = string.Empty, CssClass = "image-delete-btn" };
    del.Attributes["aria-label"] = "Remove image";
    del.ToolTip = "Remove image";
        del.OnClientClick = "return confirm('Remove the current image and delete the file from server?');";
        del.Click += (s, e) => { DeleteImageForCurrentItem(id); };
    // Inline SVG for visible cross icon
    del.Controls.Add(new Literal { Text = "<svg viewBox='0 0 24 24' xmlns='http://www.w3.org/2000/svg' aria-hidden='true' focusable='false'><path d='M18 6L6 18M6 6l12 12' stroke='currentColor' stroke-width='2' stroke-linecap='round'/></svg>" });
        wrap.Controls.Add(del);
        var fu = new FileUpload { ID = id };
        wrap.Controls.Add(fu);
        return wrap;
    }

    private Control CreateToggle(string id, string label)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var cb = new CheckBox { ID = id };
        // Apply toggle styling class and align left, matching Equipment Inventory toggles
        cb.InputAttributes["class"] = (cb.InputAttributes["class"] ?? string.Empty) + " toggle-switch";
        wrap.Controls.Add(cb);
        return wrap;
    }

    private Control CreateNumberBox(string id, string label, bool readOnly = false)
    {
        var wrap = new Panel { CssClass = "form-group" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var tb = new TextBox { ID = id, CssClass = "" };
        tb.Attributes["type"] = "number";
        tb.Attributes["step"] = "any";
        tb.Attributes["min"] = "0";
        tb.Attributes["max"] = "999.99";
        tb.Attributes["placeholder"] = "0.00";
        
        if (readOnly)
        {
            tb.ReadOnly = true;
        }
        
        wrap.Controls.Add(tb);
        return wrap;
    }

    private void AddCalPMRow(Control grid, Control toggle, Control estimatedTime, Control field1, Control field2)
    {
        // Custom row: Toggle (span-2) + Estimated Time (span-2) = span-4 (same as Location)
        // Field1 (span-4) + Field2 (span-4) = span-8
        // Total: 4 + 4 + 4 = 12 cols
        if (toggle is Panel) 
        {
            var css = ((Panel)toggle).CssClass;
            if (css.Contains("span-4")) css = css.Replace("span-4", "span-2");
            else if (!css.Contains("span-2")) css += " span-2";
            ((Panel)toggle).CssClass = css;
        }
        if (estimatedTime is Panel) 
        {
            var css = ((Panel)estimatedTime).CssClass;
            if (!css.Contains("span-2")) css += " span-2";
            ((Panel)estimatedTime).CssClass = css;
        }
        if (field1 is Panel)
        {
            var css = ((Panel)field1).CssClass;
            if (!css.Contains("span-4")) css += " span-4";
            ((Panel)field1).CssClass = css;
        }
        if (field2 is Panel)
        {
            var css = ((Panel)field2).CssClass;
            if (!css.Contains("span-4")) css += " span-4";
            ((Panel)field2).CssClass = css;
        }
        
        grid.Controls.Add(toggle);
        grid.Controls.Add(estimatedTime);
        grid.Controls.Add(field1);
        grid.Controls.Add(field2);
    }

    private void SetPreviewImage(string fileUploadId, string url)
    {
        try
        {
            var img = FindControlRecursive(phFormFields, fileUploadId + "_preview") as System.Web.UI.WebControls.Image;
            var del = FindControlRecursive(phFormFields, fileUploadId + "_delete") as LinkButton;
            var picker = FindControlRecursive(phFormFields, fileUploadId) != null ? FindControlRecursive(phFormFields, fileUploadId).Parent as Panel : null;
            if (img == null) return;
            if (!string.IsNullOrWhiteSpace(url))
            {
                url = url.Trim();
                string resolved = url;
                try
                {
                    if (url.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || url.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                    {
                        resolved = url; // already absolute
                    }
                    else if (url.StartsWith("/"))
                    {
                        // DB stored root-relative; convert to app-relative so it includes the virtual directory path
                        resolved = ResolveUrl("~" + url);
                    }
                    else
                    {
                        // Relative path (like "Uploads/Images/..."); convert to app-relative
                        resolved = ResolveUrl("~/" + url);
                    }
                }
                catch { resolved = url; }

                img.ImageUrl = resolved;
                img.Visible = true;
                // Ensure CSS display if server toggled Visible
                img.Attributes["style"] = (img.Attributes["style"] ?? string.Empty) + ";display:block;cursor:pointer;";
                // Make image clickable - open in new tab when clicked
                img.Attributes["onclick"] = "window.open('" + resolved.Replace("'", "\\'") + "', '_blank');";
                img.Attributes["title"] = "Click to view full size in new tab";
                if (del != null) del.Visible = true;
                if (picker != null)
                {
                    var cls = picker.CssClass ?? string.Empty; if (cls.IndexOf("has-image", StringComparison.OrdinalIgnoreCase) < 0) picker.CssClass = cls + " has-image";
                }
            }
            else
            {
                img.Visible = false;
                if (del != null) del.Visible = false;
                if (picker != null)
                {
                    picker.CssClass = (picker.CssClass ?? string.Empty).Replace("has-image", "").Trim();
                }
            }
        }
        catch { }
    }

    private void DeleteImageForCurrentItem(string fileUploadId)
    {
        try
        {
            if (string.IsNullOrEmpty(CurrentKey)) { ShowBanner("No item selected.", "error"); return; }
            string table = GetTableForType(CurrentType);
            string imgCol = null; string niceName = null;
            if (CurrentType.Equals("ATE", StringComparison.OrdinalIgnoreCase)) { imgCol = "ATEImage"; niceName = "ATE Image"; }
            else if (CurrentType.Equals("Asset", StringComparison.OrdinalIgnoreCase)) { imgCol = "DeviceImage"; niceName = "Device Image"; }
            else if (CurrentType.Equals("Fixture", StringComparison.OrdinalIgnoreCase)) { imgCol = "FixtureImage"; niceName = "Fixture Image"; }
            else if (CurrentType.Equals("Harness", StringComparison.OrdinalIgnoreCase)) { imgCol = "FixtureImage"; niceName = "Fixture Image"; }
            if (imgCol == null) return;

            string existingPath = null;
            using (var conn = new SqlConnection(ConnectionString))
            using (var get = new SqlCommand("SELECT " + imgCol + " FROM " + table + " WHERE EatonID=@id", conn))
            {
                get.Parameters.AddWithValue("@id", CurrentKey); conn.Open(); var o = get.ExecuteScalar(); existingPath = o == null || o == DBNull.Value ? null : o.ToString();
            }

            // Delete file on disk if exists
            if (!string.IsNullOrWhiteSpace(existingPath))
            {
                try
                {
                    string appRel = existingPath.StartsWith("~") ? existingPath.Substring(1) : existingPath;
                    string phys = Server.MapPath("~" + (appRel.StartsWith("/") ? appRel : ("/" + appRel)));
                    if (File.Exists(phys)) File.Delete(phys);
                }
                catch { }
            }

            // Clear column
            using (var conn = new SqlConnection(ConnectionString))
            using (var upd = new SqlCommand("UPDATE " + table + " SET " + imgCol + "=NULL WHERE EatonID=@id", conn))
            {
                upd.Parameters.AddWithValue("@id", CurrentKey); conn.Open(); upd.ExecuteNonQuery();
            }

            // Log change
            try
            {
                using (var conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();
                    var rec = LoadCurrentRecord(table, "EatonID", CurrentKey);
                    var name = GetRecordNameForType(CurrentType, CurrentKey,
                        rec.ContainsKey("ATEName") ? rec["ATEName"] as string :
                        (rec.ContainsKey("DeviceName") ? rec["DeviceName"] as string : null),
                        rec.ContainsKey("ModelNo") ? rec["ModelNo"] as string :
                        (rec.ContainsKey("FixtureModelNoName") ? rec["FixtureModelNoName"] as string :
                            (rec.ContainsKey("HarnessModelNo") ? rec["HarnessModelNo"] as string : null))
                    );
                    LogChange(conn, new ChangeLogEntry
                    {
                        TableName = table,
                        RecordID = CurrentKey,
                        RecordName = name,
                        ChangedBy = Session["TED:FullName"] as string ?? Context.User.Identity.Name ?? "Unknown",
                        FieldName = imgCol,
                        OldValue = existingPath ?? string.Empty,
                        NewValue = string.Empty,
                        ChangeType = "Modified"
                    });
                }
            }
            catch { }

            // Update UI: remove preview and delete button
            SetPreviewImage(fileUploadId, null);
            ShowBanner(niceName + " removed.", null);
        }
        catch (Exception ex)
        {
            ShowBanner("Failed to remove image: " + ex.Message, "error");
        }
    }

    private Control CreateReadOnly(string id, string label)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label for='" + id + "'>" + HttpUtility.HtmlEncode(label) + "</label>" });
        var tb = new TextBox { ID = id, ReadOnly = true, Enabled = false };
        tb.Attributes["aria-readonly"] = "true";
        wrap.Controls.Add(tb);
        return wrap;
    }

    private Control CreateMultiUsers(string id, string label)
    {
        // Mirror Create page multi-select: button + options (checkboxes) container
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label>" + HttpUtility.HtmlEncode(label) + "</label>" });

        var dropdown = new Panel { CssClass = "multi-select-dropdown" };
        var button = new Panel { ID = id + "_button", CssClass = "multi-select-button" };
        button.Controls.Add(new Literal { ID = id + "_content", Text = "<span class='multi-select-text'></span><span class='multi-select-arrow'></span>" });
        dropdown.Controls.Add(button);

        var options = new Panel { ID = id + "_options", CssClass = "multi-select-options" };
        dropdown.Controls.Add(options);

        wrap.Controls.Add(dropdown);
        return wrap;
    }

    private Control CreateMultiAssets(string id, string label)
    {
        var wrap = new Panel { CssClass = "form-group span-4" };
        wrap.Controls.Add(new Literal { Text = "<label>" + HttpUtility.HtmlEncode(label) + "</label>" });

        var dropdown = new Panel { CssClass = "multi-select-dropdown" };
        var button = new Panel { ID = id + "_button", CssClass = "multi-select-button" };
        button.Controls.Add(new Literal { ID = id + "_content", Text = "<span class='multi-select-text'></span><span class='multi-select-arrow'></span>" });
        dropdown.Controls.Add(button);

        var options = new Panel { ID = id + "_options", CssClass = "multi-select-options" };
        dropdown.Controls.Add(options);

        wrap.Controls.Add(dropdown);
        return wrap;
    }

    private Control Spacer()
    {
        return new Panel { CssClass = "span-4" };
    }

    private void AddRow(Control grid, params Control[] cols)
    {
        foreach (var c in cols) grid.Controls.Add(c);
    }

    // recursive finder
    private Control FindControlRecursive(Control root, string id)
    {
        if (root == null || id == null) return null;
        if (root.ID == id) return root;
        foreach (Control c in root.Controls)
        {
            var found = FindControlRecursive(c, id);
            if (found != null) return found;
        }
        return null;
    }
}
