using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Configuration;

public partial class CreateNewItem : System.Web.UI.Page
{
    private string ConnectionString
    {
        get { return ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString; }
    }

    protected void Page_Init(object sender, EventArgs e)
    {
        // Always (re)generate dynamic form controls early in lifecycle
        string itemType = GetCurrentItemType();
        GenerateForm(itemType);
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack)
        {
            // Re-initialize multi-selects after postback
            Page.ClientScript.RegisterStartupScript(this.GetType(), "reinitMultiSelect",
                "setTimeout(initializeAllMultiSelects, 100);", true);
        }
    }

    private void GenerateForm(string itemType)
    {
        phFormFields.Controls.Clear();
        pnlForm.Visible = true;

        switch (itemType.ToUpper())
        {
            case "ATE":
                GenerateATEForm();
                break;
            case "ASSET":
                GenerateAssetForm();
                break;
            case "FIXTURE":
                GenerateFixtureForm();
                break;
            case "HARNESS":
                GenerateHarnessForm();
                break;
        }

        SetHeaderTitleForType(itemType);
    }

    private string GetCurrentItemType()
    {
        string itemType = ViewState["CurrentItemType"] as string;
        if (string.IsNullOrEmpty(itemType))
        {
            itemType = Request.QueryString["type"];
        }
        if (string.IsNullOrEmpty(itemType)) itemType = "ATE"; // default
        ViewState["CurrentItemType"] = itemType;
        return itemType;
    }

    private void SetHeaderTitleForType(string itemType)
    {
        try
        {
            string title;
            switch (itemType.ToUpper())
            {
                case "ATE": title = "ATE Details"; break;
                case "ASSET": title = "Asset Details"; break;
                case "FIXTURE": title = "Fixture Details"; break;
                case "HARNESS": title = "Harness Details"; break;
                default: title = "Create New Item"; break;
            }
            var header = this.FindControl("AdminHeader1");
            if (header != null)
            {
                var prop = header.GetType().GetProperty("Title");
                if (prop != null && prop.CanWrite)
                {
                    prop.SetValue(header, title, null);
                }
            }
        }
        catch { }
    }

    private void GenerateATEForm()
    {
        // Eaton ID | ATE Name | ATE Description
        CreateFormRow(new[]
        {
            CreateTextBox("txtEatonID", "Eaton ID", false, "text", true),
            CreateTextBox("txtATEName", "ATE Name", true),
            CreateTextBox("txtATEDescription", "ATE Description", false)
        });

        // Intended Line | ATE Status | ATE Folder | Current Location (custom spans: 2, 2, 4, 4)
        CreateFormRow4ColCustom(new[]
        {
            CreateIntendedLineDropdown("ddlIntendedLine", "Intended Line"),
            CreateATEStatusDropdown("ddlATEStatus", "ATE Status"),
            CreateTextBox("txtATEFolder", "ATE Folder", false, "url", true),
            CreateLocationDropdown("ddlLocation", "Current Location")
        });

        // Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
        CreateCalPMRow(
            CreateToggle("chkRequiresCalibration", "Requires Calibration"),
            CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false, "0.0", "999.99", "0.25"),
            CreateTextBox("txtCalibrationID", "Calibration ID", false),
            CreateCalibrationFrequencyDropdown("ddlCalibrationFreq", "Calibration Frequency")
        );

        // Required PM + PM Est Time | PM Frequency | PM Responsible
        CreateCalPMRow(
            CreateToggle("chkRequiredPM", "Required PM"),
            CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false, "0.0", "999.99", "1"),
            CreatePMFrequencyDropdown("ddlPMFreq", "PM Frequency"),
            CreateUsersMultiSelectDropdown("lstPMResponsible", "PM Responsible")
        );

        // ATE Image | Comments (image 4, comments 8)
        Control ateImage = CreateFileUpload("fuATEImage", "ATE Image");
        Control comments = CreateTextArea("txtComments", "Comments");
        AddSpan(comments, 8);
        CreateFormRow(new[] { ateImage, comments });
    }

    private void GenerateAssetForm()
    {
        // Eaton ID | Model No | Device Name
        CreateFormRow(new[]
        {
            CreateTextBox("txtEatonID", "Eaton ID", false, "text", true),
            CreateTextBox("txtModelNo", "Model No", false),
            CreateTextBox("txtDeviceName", "Device Name", true)
        });

        // Device Description | ATE | Location
        CreateFormRow(new[]
        {
            CreateTextBox("txtDeviceDescription", "Device Description", false),
            CreateATEDropdown("ddlATE", "ATE"),
            CreateLocationDropdown("ddlLocation", "Location")
        });

        // Device Type | Manufacturer | Manufacturer Site
        CreateFormRow(new[]
        {
            CreateDeviceTypeDropdown("ddlDeviceType", "Device Type"),
            CreateManufacturerDropdown("ddlManufacturer", "Manufacturer"),
            CreateTextBox("txtManufacturerSite", "Manufacturer Site", false, "url")
        });

        // Device Folder | Current Status | Swap Capability
        CreateFormRow(new[]
        {
            CreateTextBox("txtDeviceFolder", "Device Folder", false, "url", true),
            CreateCurrentStatusDropdown("ddlCurrentStatus", "Current Status"),
            CreateAssetsMultiSelectDropdown("lstSwapCapability", "Swap Capability")
        });

        // Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
        CreateCalPMRow(
            CreateToggle("chkRequiresCalibration", "Requires Calibration"),
            CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false, "0.0", "999.99", "0.25"),
            CreateTextBox("txtCalibrationID", "Calibration ID", false),
            CreateCalibrationFrequencyDropdown("ddlCalibrationFreq", "Calibration Frequency")
        );

        // Required PM + PM Est Time | PM Frequency | PM Responsible
        CreateCalPMRow(
            CreateToggle("chkRequiredPM", "Required PM"),
            CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false, "0.0", "999.99", "1"),
            CreatePMFrequencyDropdown("ddlPMFreq", "PM Frequency"),
            CreateUsersMultiSelectDropdown("lstPMResponsible", "PM Responsible")
        );

        // Device Image | Comments (image 4, comments 8)
        Control deviceImage = CreateFileUpload("fuDeviceImage", "Device Image");
        Control comments = CreateTextArea("txtComments", "Comments");
        AddSpan(comments, 8);
        CreateFormRow(new[] { deviceImage, comments });
    }

    private void GenerateFixtureForm()
    {
        // Eaton ID | Fixture Model No. / Name | Fixture Description
        CreateFormRow(new[]
        {
            CreateTextBox("txtEatonID", "Eaton ID", false, "text", true),
            CreateTextBox("txtFixtureModelNo", "Fixture Model No. / Name", true),
            CreateTextBox("txtFixtureDescription", "Fixture Description", false)
        });

        // Intended Line | Current Status | Fixture Folder | Current Location (4 columns)
        CreateFormRow4ColCustom(new[]
        {
            CreateIntendedLineDropdown("ddlIntendedLine", "Intended Line"),
            CreateCurrentStatusDropdown("ddlCurrentStatus", "Current Status"),
            CreateTextBox("txtFixtureFolder", "Fixture Folder", false, "url", true),
            CreateLocationDropdown("ddlLocation", "Current Location")
        });

        // Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
        CreateCalPMRow(
            CreateToggle("chkRequiresCalibration", "Requires Calibration"),
            CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false, "0.0", "999.99", "0.25"),
            CreateTextBox("txtCalibrationID", "Calibration ID", false),
            CreateCalibrationFrequencyDropdown("ddlCalibrationFreq", "Calibration Frequency")
        );

        // Required PM + PM Est Time | PM Frequency | PM Responsible
        CreateCalPMRow(
            CreateToggle("chkRequiredPM", "Required PM"),
            CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false, "0.0", "999.99", "1"),
            CreatePMFrequencyDropdown("ddlPMFreq", "PM Frequency"),
            CreateUsersMultiSelectDropdown("lstPMResponsible", "PM Responsible")
        );

        // Fixture Image | Comments (image 4, comments 8)
        Control fixtureImage = CreateFileUpload("fuFixtureImage", "Fixture Image");
        Control comments = CreateTextArea("txtComments", "Comments");
        AddSpan(comments, 8);
        CreateFormRow(new[] { fixtureImage, comments });
    }

    private void GenerateHarnessForm()
    {
        // Eaton ID | Harness Model No. | Harness Description
        CreateFormRow(new[]
        {
            CreateTextBox("txtEatonID", "Eaton ID", false, "text", true),
            CreateTextBox("txtHarnessModelNo", "Harness Model No.", true),
            CreateTextBox("txtHarnessDescription", "Harness Description", false)
        });

        // Location | Harness Folder | Current Status
        CreateFormRow(new[]
        {
            CreateLocationDropdown("ddlLocation", "Location"),
            CreateTextBox("txtHarnessFolder", "Harness Folder", false, "url", true),
            CreateCurrentStatusDropdown("ddlCurrentStatus", "Current Status")
        });

        // Requires Calibration + Cal Est Time | Calibration ID | Calibration Frequency
        CreateCalPMRow(
            CreateToggle("chkRequiresCalibration", "Requires Calibration"),
            CreateNumberBox("txtCalEstimatedTime", "Cal Estimated Time (Hours)", false, "0.0", "999.99", "0.25"),
            CreateTextBox("txtCalibrationID", "Calibration ID", false),
            CreateCalibrationFrequencyDropdown("ddlCalibrationFreq", "Calibration Frequency")
        );

        // Required PM + PM Est Time | PM Frequency | PM Responsible
        CreateCalPMRow(
            CreateToggle("chkRequiredPM", "Required PM"),
            CreateNumberBox("txtPMEstimatedTime", "PM Estimated Time (Minutes)", false, "0.0", "999.99", "1"),
            CreatePMFrequencyDropdown("ddlPMFreq", "PM Frequency"),
            CreateUsersMultiSelectDropdown("lstPMResponsible", "PM Responsible")
        );

        // Harness Image | Comments (image 4, comments 8)
        Control harnessImage = CreateFileUpload("fuHarnessImage", "Harness Image");
        Control comments = CreateTextArea("txtComments", "Comments");
        AddSpan(comments, 8);
        CreateFormRow(new[] { harnessImage, comments });
    }

    #region Form Control Creation Methods

    private void CreateFormRow(Control[] controls)
    {
        // 3 fields per row using Admin grid spans
        Panel row = new Panel();
        row.CssClass = "form-grid";

        foreach (Control control in controls)
        {
            // Ensure each group spans 4 columns
            if (control is Panel)
            {
                ((Panel)control).CssClass = ((Panel)control).CssClass + " span-4";
            }
            row.Controls.Add(control);
        }

        phFormFields.Controls.Add(row);
    }

    private void CreateFormRow4Col(Control[] controls)
    {
        // 4 fields per row - each spans 3 columns (12 / 4 = 3)
        Panel row = new Panel();
        row.CssClass = "form-grid";

        foreach (Control control in controls)
        {
            // Ensure each group spans 3 columns for 4-column layout
            if (control is Panel)
            {
                ((Panel)control).CssClass = ((Panel)control).CssClass + " span-3";
            }
            row.Controls.Add(control);
        }

        phFormFields.Controls.Add(row);
    }

    private void CreateCalPMRow(Control toggle, Control estimatedTime, Control field1, Control field2)
    {
        // Custom row: Toggle + Estimated Time should equal Location field width (4 cols total)
        // Toggle (2 cols) + Estimated Time (2 cols) = 4 cols (same as Location)
        // Field1 (4 cols) + Field2 (4 cols) = 8 cols
        // Total: 4 + 4 + 4 = 12 cols
        Panel row = new Panel();
        row.CssClass = "form-grid";

        if (toggle is Panel) ((Panel)toggle).CssClass = ((Panel)toggle).CssClass + " span-2";
        if (estimatedTime is Panel) ((Panel)estimatedTime).CssClass = ((Panel)estimatedTime).CssClass + " span-2";
        if (field1 is Panel) ((Panel)field1).CssClass = ((Panel)field1).CssClass + " span-4";
        if (field2 is Panel) ((Panel)field2).CssClass = ((Panel)field2).CssClass + " span-4";

        row.Controls.Add(toggle);
        row.Controls.Add(estimatedTime);
        row.Controls.Add(field1);
        row.Controls.Add(field2);

        phFormFields.Controls.Add(row);
    }

    private void CreateFormRow4ColCustom(Control[] controls)
    {
        // Custom 4-column layout: Intended Line (2) | ATE Status (2) | ATE Folder (4) | Current Location (4)
        Panel row = new Panel();
        row.CssClass = "form-grid";

        // Set custom spans: 2, 2, 4, 4
        if (controls.Length >= 1 && controls[0] is Panel) ((Panel)controls[0]).CssClass = ((Panel)controls[0]).CssClass + " span-2"; // Intended Line
        if (controls.Length >= 2 && controls[1] is Panel) ((Panel)controls[1]).CssClass = ((Panel)controls[1]).CssClass + " span-2"; // ATE Status
        if (controls.Length >= 3 && controls[2] is Panel) ((Panel)controls[2]).CssClass = ((Panel)controls[2]).CssClass + " span-4"; // ATE Folder
        if (controls.Length >= 4 && controls[3] is Panel) ((Panel)controls[3]).CssClass = ((Panel)controls[3]).CssClass + " span-4"; // Current Location

        foreach (Control control in controls)
        {
            row.Controls.Add(control);
        }

        phFormFields.Controls.Add(row);
    }

    private Panel CreateTextBox(string id, string label, bool required = false, string inputType = "text", bool disabled = false)
    {
        Panel group = new Panel();
    group.CssClass = "form-group"; // span-4 is applied by row builder

        Label lbl = new Label();
        lbl.Text = label + (required ? " *" : "");
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        TextBox txt = new TextBox();
        txt.ID = id;
        txt.CssClass = "form-control";
        if (inputType == "url") txt.TextMode = TextBoxMode.Url;
        if (disabled) txt.Enabled = false;
        group.Controls.Add(txt);

        return group;
    }

    private Panel CreateNumberBox(string id, string label, bool required = false, string min = "0", string max = "999.99", string step = "0.01")
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label + (required ? " *" : "");
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        TextBox txt = new TextBox();
        txt.ID = id;
        txt.Attributes["type"] = "number";
        txt.Attributes["min"] = min;
        txt.Attributes["max"] = max;
        txt.Attributes["step"] = step;
        txt.Attributes["placeholder"] = "0.00";
        group.Controls.Add(txt);

        return group;
    }

    private Panel CreateTextArea(string id, string label, bool required = false)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label + (required ? " *" : "");
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        TextBox txt = new TextBox();
        txt.ID = id;
        txt.TextMode = TextBoxMode.MultiLine;
        txt.Rows = 3;
        txt.CssClass = "form-control";
        group.Controls.Add(txt);

        return group;
    }

    private Panel CreateToggle(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        // Create label using Literal (same as ItemDetails)
        group.Controls.Add(new Literal { Text = "<label>" + HttpUtility.HtmlEncode(label) + "</label>" });
        

        // Create the toggle as a SPAN wrapper with an INPUT inside (raw HTML approach)
        // This ensures clean rendering without ASP.NET control baggage
        var toggleHtml = string.Format(
            "<span><input type='checkbox' id='{0}' name='{0}' class='toggle-switch' /></span>",
            id
        );
        group.Controls.Add(new Literal { Text = toggleHtml });

        return group;
    }

    private void AddSpan(Control control, int columns)
    {
        if (control is Panel)
        {
            ((Panel)control).CssClass += " span-" + columns;
        }
    }

    private Panel CreateFileUpload(string id, string label)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.CssClass = "form-label";
        group.Controls.Add(lbl);

        Panel uploadContainer = new Panel { CssClass = "file-upload-container" };
        // Visible skin
        uploadContainer.Controls.Add(new Literal { Text = "<div class='file-upload-visual'><span class='file-btn'>Choose File</span><span class='file-name'>No file chosen</span></div>" });
        // Actual input overlay
        FileUpload fu = new FileUpload { ID = id, CssClass = "file-upload-input" };
        fu.Attributes["onchange"] = "var v=this.value.split('\\\\').pop(); var wrap=this.parentNode.querySelector('.file-name'); if(wrap){ wrap.textContent=v||'No file chosen'; }";
        uploadContainer.Controls.Add(fu);
        group.Controls.Add(uploadContainer);
        return group;
    }

    private Panel CreateIntendedLineDropdown(string id, string label)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateIntendedLineDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateLocationDropdown(string id, string label)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateLocationDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateCurrentStatusDropdown(string id, string label)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateCurrentStatusDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateATEStatusDropdown(string id, string label)
    {
        Panel group = new Panel();
    group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateATEStatusDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateCalibrationFrequencyDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("Every 6 Months", "Every 6 Months"));
        ddl.Items.Add(new ListItem("Every Year", "Every Year"));
        ddl.Items.Add(new ListItem("Every 2 Years", "Every 2 Years"));
        ddl.Items.Add(new ListItem("Every 5 Years", "Every 5 Years"));
        ddl.Items.Add(new ListItem("N/A", "N/A"));
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreatePMFrequencyDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("Every Month", "Every Month"));
        ddl.Items.Add(new ListItem("Every 3 Months", "Every 3 Months"));
        ddl.Items.Add(new ListItem("Every 4 Months", "Every 4 Months"));
        ddl.Items.Add(new ListItem("Every 6 Months", "Every 6 Months"));
        ddl.Items.Add(new ListItem("Every Year", "Every Year"));
        ddl.Items.Add(new ListItem("N/A", "N/A"));
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateDeviceTypeDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateDeviceTypeDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateManufacturerDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateManufacturerDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateATEDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.AssociatedControlID = id;
        group.Controls.Add(lbl);

        DropDownList ddl = new DropDownList();
        ddl.ID = id;
        ddl.CssClass = "form-control";
        PopulateATEDropdown(ddl);
        group.Controls.Add(ddl);

        return group;
    }

    private Panel CreateUsersMultiSelectDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.CssClass = "form-label";
        lbl.AssociatedControlID = id + "_button";
        group.Controls.Add(lbl);

        Panel dropdown = new Panel();
        dropdown.CssClass = "multi-select-dropdown";

        // Create the button
        Panel button = new Panel();
        button.ID = id + "_button";
        button.CssClass = "multi-select-button";

    Literal buttonContent = new Literal();
    buttonContent.ID = id + "_content";
    // Use CSS-drawn arrow (no unicode) to avoid encoding glitches
    buttonContent.Text = "<span class='multi-select-text' style='font-size:13px;'>Select options...</span><span class='multi-select-arrow'></span>";
    button.Controls.Add(buttonContent);

        dropdown.Controls.Add(button);

        // Create the options container
        Panel options = new Panel();
        options.ID = id + "_options";
        options.CssClass = "multi-select-options";

        PopulateUsersMultiSelectDropdown(options, id);

        dropdown.Controls.Add(options);
        group.Controls.Add(dropdown);

        return group;
    }

    private Panel CreateAssetsMultiSelectDropdown(string id, string label)
    {
        Panel group = new Panel();
        group.CssClass = "form-group";

        Label lbl = new Label();
        lbl.Text = label;
        lbl.CssClass = "form-label";
        lbl.AssociatedControlID = id + "_button";
        group.Controls.Add(lbl);

        Panel dropdown = new Panel();
        dropdown.CssClass = "multi-select-dropdown";

        // Create the button
        Panel button = new Panel();
        button.ID = id + "_button";
        button.CssClass = "multi-select-button";

    Literal buttonContent = new Literal();
    buttonContent.ID = id + "_content";
    // Use CSS-drawn arrow (no unicode) to avoid encoding glitches
    buttonContent.Text = "<span class='multi-select-text' style='font-size:13px;'>Select options...</span><span class='multi-select-arrow'></span>";
    button.Controls.Add(buttonContent);

        dropdown.Controls.Add(button);

        // Create the options container
        Panel options = new Panel();
        options.ID = id + "_options";
        options.CssClass = "multi-select-options";

        PopulateAssetsMultiSelectDropdown(options, id);

        dropdown.Controls.Add(options);
        group.Controls.Add(dropdown);

        return group;
    }

    #endregion

    #region Dropdown Population Methods

    private void PopulateLocationDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT DISTINCT StationSubLineCode FROM TestStation_Bay WHERE StationSubLineCode IS NOT NULL AND StationSubLineCode != '' ORDER BY StationSubLineCode";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string location = reader["StationSubLineCode"].ToString();
                            ddl.Items.Add(new ListItem(location, location));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log error and add fallback option
            ddl.Items.Add(new ListItem("Error loading locations", ""));
        }
    }

    private void PopulateIntendedLineDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT ProductionLineID, ProductionLineName FROM ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string id = reader["ProductionLineID"].ToString();
                            string name = reader["ProductionLineName"].ToString();
                            ddl.Items.Add(new ListItem(name, id));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // Log error and add fallback option
            ddl.Items.Add(new ListItem("Error loading intended lines", ""));
        }
    }

    private void PopulateCurrentStatusDropdown(DropDownList ddl)
    {
        // Current Status dropdown options as specified
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("In Use", "In Use"));
        ddl.Items.Add(new ListItem("Spare", "Spare"));
        ddl.Items.Add(new ListItem("Out of Service - Damaged", "Out of Service - Damaged"));
        ddl.Items.Add(new ListItem("Out of Service - Under Repair", "Out of Service - Under Repair"));
        ddl.Items.Add(new ListItem("Out of Service - In Calibration", "Out of Service - In Calibration"));
        ddl.Items.Add(new ListItem("Scraped / Returned to vendor", "Scraped / Returned to vendor"));
    }

    private void PopulateATEStatusDropdown(DropDownList ddl)
    {
        // ATE Status dropdown options as specified
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));
        ddl.Items.Add(new ListItem("In Use", "In Use"));
        ddl.Items.Add(new ListItem("Spare", "Spare"));
        ddl.Items.Add(new ListItem("Out of Service - Damaged", "Out of Service - Damaged"));
        ddl.Items.Add(new ListItem("Out of Service - Under Repair", "Out of Service - Under Repair"));
        ddl.Items.Add(new ListItem("Scraped", "Scraped"));
    }

    private void PopulateDeviceTypeDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));

        // Add predefined device types
        ddl.Items.Add(new ListItem("Digital Power Meter", "Digital Power Meter"));
        ddl.Items.Add(new ListItem("Hand Meter", "Hand Meter"));
        ddl.Items.Add(new ListItem("AC Programable Power Supply", "AC Programable Power Supply"));
        ddl.Items.Add(new ListItem("DC Power Supply", "DC Power Supply"));
        ddl.Items.Add(new ListItem("Transformer", "Transformer"));
        ddl.Items.Add(new ListItem("Electrical Safety Analyzer", "Electrical Safety Analyzer"));
        ddl.Items.Add(new ListItem("Digital I/O Interface", "Digital I/O Interface"));
        ddl.Items.Add(new ListItem("Digital Multimeter", "Digital Multimeter"));
        ddl.Items.Add(new ListItem("Oscilloscope", "Oscilloscope"));
        ddl.Items.Add(new ListItem("Power Supply", "Power Supply"));
        ddl.Items.Add(new ListItem("Function Generator", "Function Generator"));
        ddl.Items.Add(new ListItem("Spectrum Analyzer", "Spectrum Analyzer"));
        ddl.Items.Add(new ListItem("Logic Analyzer", "Logic Analyzer"));
        ddl.Items.Add(new ListItem("Network Analyzer", "Network Analyzer"));
        ddl.Items.Add(new ListItem("Signal Generator", "Signal Generator"));
        ddl.Items.Add(new ListItem("Frequency Counter", "Frequency Counter"));
        ddl.Items.Add(new ListItem("LCR Meter", "LCR Meter"));
        ddl.Items.Add(new ListItem("Temperature Chamber", "Temperature Chamber"));
        ddl.Items.Add(new ListItem("Environmental Chamber", "Environmental Chamber"));
        ddl.Items.Add(new ListItem("Load Bank", "Load Bank"));
        ddl.Items.Add(new ListItem("Electronic Load", "Electronic Load"));
        ddl.Items.Add(new ListItem("Calibrator", "Calibrator"));
        ddl.Items.Add(new ListItem("Other", "Other"));
    }

    private void PopulateManufacturerDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));

        // Add predefined manufacturers
        ddl.Items.Add(new ListItem("National Instruments", "National Instruments"));
        ddl.Items.Add(new ListItem("Fluke", "Fluke"));
        ddl.Items.Add(new ListItem("Yokogawa", "Yokogawa"));
        ddl.Items.Add(new ListItem("California Instruments", "California Instruments"));
        ddl.Items.Add(new ListItem("Agilent", "Agilent"));
        ddl.Items.Add(new ListItem("CableScan", "CableScan"));
        ddl.Items.Add(new ListItem("SeaLevel", "SeaLevel"));
        ddl.Items.Add(new ListItem("Keysight", "Keysight"));
        ddl.Items.Add(new ListItem("Associated Research", "Associated Research"));
        ddl.Items.Add(new ListItem("Vitrek", "Vitrek"));
        ddl.Items.Add(new ListItem("Eaton", "Eaton"));
        ddl.Items.Add(new ListItem("Other", "Other"));
    }

    private void PopulateATEDropdown(DropDownList ddl)
    {
        ddl.Items.Clear();
        ddl.Items.Add(new ListItem("", ""));

        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT ATEInventoryID, ATEName FROM ATE_Inventory WHERE ATEName IS NOT NULL ORDER BY ATEName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string id = reader["ATEInventoryID"].ToString();
                            string name = reader["ATEName"].ToString();
                            ddl.Items.Add(new ListItem(name, id));
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ddl.Items.Add(new ListItem("Error loading ATE items", ""));
        }
    }

    private void PopulateUsersMultiSelectDropdown(Panel container, string baseName)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT UserID, FullName FROM Users WHERE IsActive = 1 ORDER BY FullName";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Panel option = new Panel();
                            option.CssClass = "multi-select-option";

                            CheckBox chk = new CheckBox();
                            chk.ID = baseName + "_" + reader["UserID"].ToString();
                            chk.Attributes["data-value"] = reader["UserID"].ToString();
                            chk.InputAttributes["aria-label"] = reader["FullName"].ToString();
                            chk.InputAttributes["data-label"] = reader["FullName"].ToString();

                            Literal text = new Literal();
                            text.Text = "<span class='multi-select-option-label'>" + HttpUtility.HtmlEncode(reader["FullName"].ToString()) + "</span>";

                            option.Controls.Add(chk);
                            option.Controls.Add(text);
                            container.Controls.Add(option);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Panel errorOption = new Panel();
            errorOption.CssClass = "multi-select-option";
            Label errorLabel = new Label();
            errorLabel.Text = "Error loading users";
            errorOption.Controls.Add(errorLabel);
            container.Controls.Add(errorOption);
        }
    }

    private void PopulateAssetsMultiSelectDropdown(Panel container, string baseName)
    {
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                string query = "SELECT AssetID, ModelNo FROM Asset_Inventory WHERE ModelNo IS NOT NULL ORDER BY ModelNo";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Panel option = new Panel();
                            option.CssClass = "multi-select-option";

                            CheckBox chk = new CheckBox();
                            chk.ID = baseName + "_" + reader["AssetID"].ToString();
                            chk.Attributes["data-value"] = reader["AssetID"].ToString();
                            chk.InputAttributes["aria-label"] = reader["ModelNo"].ToString();
                            chk.InputAttributes["data-label"] = reader["ModelNo"].ToString();

                            Literal text = new Literal();
                            text.Text = "<span class='multi-select-option-label'>" + HttpUtility.HtmlEncode(reader["ModelNo"].ToString()) + "</span>";

                            option.Controls.Add(chk);
                            option.Controls.Add(text);
                            container.Controls.Add(option);
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            Panel errorOption = new Panel();
            errorOption.CssClass = "multi-select-option";
            Label errorLabel = new Label();
            errorLabel.Text = "Error loading assets";
            errorOption.Controls.Add(errorLabel);
            container.Controls.Add(errorOption);
        }
    }

    #endregion

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        try
        {
            string itemType = GetCurrentItemType();

            // Server-side validation for PM Responsible
            bool requiredPM = GetChecked("chkRequiredPM");
            if (requiredPM)
            {
                string pmResponsible = GetMultiSelectCsv("lstPMResponsible");
                if (string.IsNullOrWhiteSpace(pmResponsible))
                {
                    ShowMessage("PM Responsible is required when Required PM is enabled.", "error");
                    return;
                }
            }

            switch (itemType.ToUpper())
            {
                case "ATE":
                    CreateATEItem();
                    break;
                case "ASSET":
                    CreateAssetItem();
                    break;
                case "FIXTURE":
                    CreateFixtureItem();
                    break;
                case "HARNESS":
                    CreateHarnessItem();
                    break;
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error creating item: " + ex.Message, "error");
        }
    }

    protected void btnClear_Click(object sender, EventArgs e)
    {
        // Clear all form controls
        ClearFormControls(phFormFields);
        ShowMessage("Form cleared.", "success");
    }

    protected void btnGoBack_Click(object sender, EventArgs e)
    {
        // Navigate back to Equipment Inventory Dashboard page
        Response.Redirect("EquipmentInventoryDashboard.aspx");
    }

    private void ClearFormControls(Control container)
    {
        foreach (Control control in container.Controls)
        {
            if (control is TextBox)
            {
                ((TextBox)control).Text = "";
            }
            else if (control is DropDownList)
            {
                ((DropDownList)control).SelectedIndex = 0;
            }
            else if (control is CheckBox)
            {
                ((CheckBox)control).Checked = false;
            }
            else if (control.HasControls())
            {
                ClearFormControls(control);
            }
        }
    }

    #region Eaton ID Generation Methods

    private string GenerateATEEatonID(string intendedLine)
    {
        // Format: YPO-ATE-[ProductionLine]-###
        // Example: YPO-ATE-SPD-005
        // Extract production line (part before first hyphen)
        string productionLine = intendedLine;
        if (!string.IsNullOrEmpty(intendedLine) && intendedLine.Contains("-"))
        {
            productionLine = intendedLine.Substring(0, intendedLine.IndexOf("-")).Trim();
        }
        
        string prefix = "YPO-ATE-" + productionLine;
        
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();
            string query = @"SELECT COUNT(*) FROM ATE_Inventory 
                           WHERE EatonID LIKE @Prefix + '-%'";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                int count = (int)cmd.ExecuteScalar();
                int nextNumber = count + 1;
                return string.Format("{0}-{1:D3}", prefix, nextNumber);
            }
        }
    }

    private string GenerateAssetEatonID(string deviceType)
    {
        // Format: YPO-AST-[DeviceType 3 Letters]-###
        // Example: YPO-AST-DMM-003
        string deviceTypeAbbr = GetDeviceTypeAbbreviation(deviceType);
        string prefix = "YPO-AST-" + deviceTypeAbbr;
        
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();
            string query = @"SELECT COUNT(*) FROM Asset_Inventory 
                           WHERE EatonID LIKE @Prefix + '-%'";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                int count = (int)cmd.ExecuteScalar();
                int nextNumber = count + 1;
                return string.Format("{0}-{1:D3}", prefix, nextNumber);
            }
        }
    }

    private string GenerateFixtureEatonID(string intendedLine)
    {
        // Format: YPO-FIX-[ProductionLine]-###
        // Example: YPO-FIX-rPDU-002
        // Extract production line (part before first hyphen)
        string productionLine = intendedLine;
        if (!string.IsNullOrEmpty(intendedLine) && intendedLine.Contains("-"))
        {
            productionLine = intendedLine.Substring(0, intendedLine.IndexOf("-")).Trim();
        }
        
        string prefix = "YPO-FIX-" + productionLine;
        
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();
            string query = @"SELECT COUNT(*) FROM Fixture_Inventory 
                           WHERE EatonID LIKE @Prefix + '-%'";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                int count = (int)cmd.ExecuteScalar();
                int nextNumber = count + 1;
                return string.Format("{0}-{1:D3}", prefix, nextNumber);
            }
        }
    }

    private string GenerateHarnessEatonID(string harnessModelNo)
    {
        // Format: YPO-HAR-[HarnessModelNo]-###
        // Example: YPO-HAR-BTLN-006
        string prefix = "YPO-HAR-" + harnessModelNo;
        
        using (SqlConnection conn = new SqlConnection(ConnectionString))
        {
            conn.Open();
            string query = @"SELECT COUNT(*) FROM Harness_Inventory 
                           WHERE EatonID LIKE @Prefix + '-%'";
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@Prefix", prefix);
                int count = (int)cmd.ExecuteScalar();
                int nextNumber = count + 1;
                return string.Format("{0}-{1:D3}", prefix, nextNumber);
            }
        }
    }

    private string GetDeviceTypeAbbreviation(string deviceType)
    {
        // Map device types to 3-letter abbreviations
        Dictionary<string, string> abbreviations = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase)
        {
            {"Digital Power Meter", "DPM"},
            {"Hand Meter", "HMT"},
            {"AC Programable Power Supply", "ACP"},
            {"DC Power Supply", "DCP"},
            {"Transformer", "TRF"},
            {"Electrical Safety Analyzer", "ESA"},
            {"Digital I/O Interface", "DIO"},
            {"Digital Multi-Meter", "DMM"},
            {"Digital Multimeter", "DMM"},
            {"Oscilloscope", "OSC"},
            {"Power Supply", "PSU"},
            {"Function Generator", "FGN"},
            {"Spectrum Analyzer", "SPA"},
            {"Logic Analyzer", "LGA"},
            {"Network Analyzer", "NWA"},
            {"Signal Generator", "SGN"},
            {"Frequency Counter", "FRC"},
            {"LCR Meter", "LCR"},
            {"Temperature Chamber", "TEC"},
            {"Environmental Chamber", "ENV"},
            {"Thermal Chamber", "THC"},
            {"Load Bank", "LDB"},
            {"Electronic Load", "ELD"},
            {"Decade Box", "DEC"},
            {"Calibrator", "CAL"},
            {"Torque Wrench", "TRW"},
            {"Crimper", "CRP"},
            {"Soldering Station", "SLD"},
            {"Hot Air Station", "HAS"},
            {"Microscope", "MIC"},
            {"Magnifier", "MAG"},
            {"Camera", "CAM"},
            {"Computer", "PC"},
            {"Laptop", "LAP"},
            {"Monitor", "MON"},
            {"Printer", "PRT"},
            {"Scanner", "SCN"},
            {"Label Maker", "LBL"},
            {"Barcode Scanner", "BAR"},
            {"Scale", "SCL"},
            {"Caliper", "CLR"},
            {"Micrometer", "MCR"},
            {"Gauge", "GAG"},
            {"Thermometer", "THM"},
            {"Hygrometer", "HYG"},
            {"Other", "OTH"}
        };

        if (abbreviations.ContainsKey(deviceType))
        {
            return abbreviations[deviceType];
        }
        
        // If not found, create abbreviation from first 3 letters
        return deviceType.Length >= 3 ? deviceType.Substring(0, 3).ToUpper() : deviceType.ToUpper().PadRight(3, 'X');
    }

    #endregion

    private void CreateATEItem()
    {
        string ateName = GetText("txtATEName");
        string ateDesc = GetText("txtATEDescription");
        string intendedLine = GetSelectedText("ddlIntendedLine");
        string location = GetSelectedText("ddlLocation");
        
        // Generate Eaton ID automatically using Intended Line
        string eatonId = GenerateATEEatonID(intendedLine);
        
        string ateFolder = GetText("txtATEFolder");
        string ateStatus = GetSelectedText("ddlATEStatus");
        bool requiresCal = GetChecked("chkRequiresCalibration");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetSelectedText("ddlCalibrationFreq");
        decimal? calEstTime = GetDecimal("txtCalEstimatedTime");
        bool requiredPM = GetChecked("chkRequiredPM");
        string pmFreq = GetSelectedText("ddlPMFreq");
        string pmResponsible = GetMultiSelectCsv("lstPMResponsible");
        decimal? pmEstTime = GetDecimal("txtPMEstimatedTime");
        string comments = GetText("txtComments");

        string ateImagePath = SaveUpload("fuATEImage", "Uploads/Images/ATE");
        int? testStationId = ResolveTestStationId(location);

             using (SqlConnection conn = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"INSERT INTO ATE_Inventory 
            (EatonID, ATEName, ATEDescription, Location, ATEFolder, ATEImage, ATEStatus,
             RequiresCalibration, CalibrationID, CalibrationFrequency, CalibrationEstimatedTime, RequiredPM, PMFrequency,
           PMResponsible, PMEstimatedTime, Comments, TestStationID, CreatedDate, CreatedBy)
            VALUES (@EatonID, @ATEName, @ATEDescription, @Location, @ATEFolder, @ATEImage, @ATEStatus,
           @RequiresCalibration, @CalibrationID, @CalibrationFrequency, @CalEstTime, @RequiredPM, @PMFrequency,
           @PMResponsible, @PMEstTime, @Comments, @TestStationID, GETDATE(), @CreatedBy);", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)NullableString(eatonId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEName", ateName ?? "");
            cmd.Parameters.AddWithValue("@ATEDescription", (object)NullableString(ateDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableString(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEFolder", (object)NullableString(ateFolder) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEImage", (object)NullableString(ateImagePath) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ATEStatus", (object)NullableString(ateStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableString(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableString(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalEstTime", (object)calEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableString(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableString(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMEstTime", (object)pmEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableString(comments) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@TestStationID", (object)testStationId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CreatedBy", (object)NullableString(GetCurrentENumber()) ?? DBNull.Value);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        // Change log: New ATE item
        try
        {
            var recordName = !string.IsNullOrWhiteSpace(ateName) ? ateName : (!string.IsNullOrWhiteSpace(eatonId) ? eatonId : "ATE Record");
            LogChangeEntry("dbo.ATE_Inventory", eatonId ?? string.Empty, recordName, "Record Created", string.Empty, recordName, "Created");
        }
        catch { }

        // Create local file system folder for this equipment
        string folderPath = null;
        try
        {
            bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("ATE", eatonId);
            if (folderCreated)
            {
                folderPath = LocalFileSystemService.GetEquipmentFolderPath("ATE", eatonId);
                
                // Update the database with the relative folder path (without server name for portability)
                if (!string.IsNullOrEmpty(folderPath))
                {
                    // Convert to relative path by removing the base storage path
                    string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                    string relativePath = folderPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                        ? folderPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                        : folderPath;
                    
                    // Ensure it starts with Storage/ for consistency
                    if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                    {
                        relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                    }
                    
                    using (SqlConnection conn = new SqlConnection(ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("UPDATE ATE_Inventory SET ATEFolder = @FolderPath WHERE EatonID = @EatonID", conn))
                    {
                        cmd.Parameters.AddWithValue("@FolderPath", relativePath);
                        cmd.Parameters.AddWithValue("@EatonID", eatonId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                ShowMessage("ATE item created successfully. Document folder created.", "success");
            }
            else
            {
                string error = LocalFileSystemService.GetLastError();
                ShowMessage("ATE item created successfully. Folder creation failed: " + error, "warning");
            }
        }
        catch (Exception ex)
        {
            ShowMessage("ATE item created successfully. (Folder error: " + ex.Message + ")", "warning");
        }
        
        ClearFormControls(phFormFields);
    }

    private void CreateAssetItem()
    {
        string modelNo = GetText("txtModelNo");
        string deviceName = GetText("txtDeviceName");
        string deviceDesc = GetText("txtDeviceDescription");
        string ateIdStr = GetSelectedValue("ddlATE");
        string location = GetSelectedText("ddlLocation");
        string deviceType = GetSelectedText("ddlDeviceType");
        
        // Generate Eaton ID automatically based on device type
        string eatonId = GenerateAssetEatonID(deviceType);
        
        string manufacturer = GetSelectedText("ddlManufacturer");
        string manufacturerSite = GetText("txtManufacturerSite");
        string deviceFolder = GetText("txtDeviceFolder");
        string currentStatus = GetSelectedText("ddlCurrentStatus");
        string swapCapability = GetMultiSelectCsv("lstSwapCapability");
        bool requiresCal = GetChecked("chkRequiresCalibration");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetSelectedText("ddlCalibrationFreq");
        bool requiredPM = GetChecked("chkRequiredPM");
        string pmFreq = GetSelectedText("ddlPMFreq");
        string pmResponsible = GetMultiSelectCsv("lstPMResponsible");
        string comments = GetText("txtComments");
        decimal? calEstTime = GetDecimal("txtCalEstimatedTime");
        decimal? pmEstTime = GetDecimal("txtPMEstimatedTime");

        string deviceImagePath = SaveUpload("fuDeviceImage", "Uploads/Images/Assets");
        int? testStationId = ResolveTestStationId(location);

             using (SqlConnection conn = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"INSERT INTO Asset_Inventory 
            (EatonID, ModelNo, DeviceName, DeviceDescription, ATE, Location, DeviceType, Manufacturer,
             ManufacturerSite, DeviceFolder, DeviceImage, CurrentStatus, RequiresCalibration, CalibrationID,
           CalibrationFrequency, CalibrationEstimatedTime, RequiredPM, PMFrequency, PMEstimatedTime, PMResponsible, SwapCapability, Comments, TestStationID, CreatedDate, CreatedBy)
            VALUES (@EatonID, @ModelNo, @DeviceName, @DeviceDescription, @ATE, @Location, @DeviceType, @Manufacturer,
           @ManufacturerSite, @DeviceFolder, @DeviceImage, @CurrentStatus, @RequiresCalibration, @CalibrationID,
           @CalibrationFrequency, @CalEstTime, @RequiredPM, @PMFrequency, @PMEstTime, @PMResponsible, @SwapCapability, @Comments, @TestStationID, GETDATE(), @CreatedBy);", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)NullableString(eatonId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ModelNo", (object)NullableString(modelNo) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceName", deviceName ?? "");
            cmd.Parameters.AddWithValue("@DeviceDescription", (object)NullableString(deviceDesc) ?? DBNull.Value);
            // store ATE display name if we have the ID
            cmd.Parameters.AddWithValue("@ATE", (object)ResolveATEName(ateIdStr) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableString(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceType", (object)NullableString(deviceType) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Manufacturer", (object)NullableString(manufacturer) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@ManufacturerSite", (object)NullableString(manufacturerSite) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceFolder", (object)NullableString(deviceFolder) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@DeviceImage", (object)NullableString(deviceImagePath) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableString(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableString(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableString(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalEstTime", (object)calEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableString(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMEstTime", (object)pmEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableString(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@SwapCapability", (object)NullableString(swapCapability) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableString(comments) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@TestStationID", (object)testStationId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CreatedBy", (object)NullableString(GetCurrentENumber()) ?? DBNull.Value);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        // Change log: New Asset item
        try
        {
            var recordName = !string.IsNullOrWhiteSpace(deviceName) ? deviceName : (!string.IsNullOrWhiteSpace(modelNo) ? modelNo : (eatonId ?? "Asset Record"));
            LogChangeEntry("dbo.Asset_Inventory", eatonId ?? string.Empty, recordName, "Record Created", string.Empty, recordName, "Created");
        }
        catch { }

        // Create local file system folder for this equipment
        string folderPath = null;
        try
        {
            bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Asset", eatonId);
            if (folderCreated)
            {
                folderPath = LocalFileSystemService.GetEquipmentFolderPath("Asset", eatonId);
                
                // Update the database with the relative folder path (without server name for portability)
                if (!string.IsNullOrEmpty(folderPath))
                {
                    // Convert to relative path by removing the base storage path
                    string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                    string relativePath = folderPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                        ? folderPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                        : folderPath;
                    
                    // Ensure it starts with Storage/ for consistency
                    if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                    {
                        relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                    }
                    
                    using (SqlConnection conn = new SqlConnection(ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("UPDATE Asset_Inventory SET DeviceFolder = @FolderPath WHERE EatonID = @EatonID", conn))
                    {
                        cmd.Parameters.AddWithValue("@FolderPath", relativePath);
                        cmd.Parameters.AddWithValue("@EatonID", eatonId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                ShowMessage("Asset item created successfully. Document folder created.", "success");
            }
            else
            {
                string error = LocalFileSystemService.GetLastError();
                ShowMessage("Asset item created successfully. Folder creation failed: " + error, "warning");
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Asset item created successfully. (Folder error: " + ex.Message + ")", "warning");
        }
        
        ClearFormControls(phFormFields);
    }

    private void CreateFixtureItem()
    {
        string modelNo = GetText("txtFixtureModelNo");
        string fixtureDesc = GetText("txtFixtureDescription");
        string intendedLine = GetSelectedText("ddlIntendedLine");
        string location = GetSelectedText("ddlLocation");
        
        // Generate Eaton ID automatically based on Intended Line
        string eatonId = GenerateFixtureEatonID(intendedLine);
        
        string fixtureFolder = GetText("txtFixtureFolder");
        string currentStatus = GetSelectedText("ddlCurrentStatus");
        bool requiresCal = GetChecked("chkRequiresCalibration");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetSelectedText("ddlCalibrationFreq");
        bool requiredPM = GetChecked("chkRequiredPM");
        string pmFreq = GetSelectedText("ddlPMFreq");
        string pmResponsible = GetMultiSelectCsv("lstPMResponsible");
        string comments = GetText("txtComments");
        decimal? calEstTime = GetDecimal("txtCalEstimatedTime");
        decimal? pmEstTime = GetDecimal("txtPMEstimatedTime");

        string fixtureImagePath = SaveUpload("fuFixtureImage", "Uploads/Images/Fixtures");
        int? testStationId = ResolveTestStationId(location);

       using (SqlConnection conn = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"INSERT INTO Fixture_Inventory 
            (EatonID, FixtureModelNoName, FixtureDescription, Location, FixtureFolder, FixtureImage, CurrentStatus,
           RequiresCalibration, CalibrationID, CalibrationFrequency, CalibrationEstimatedTime, RequiredPM, PMFrequency, PMEstimatedTime, PMResponsible, Comments, TestStationID, CreatedDate, CreatedBy)
            VALUES (@EatonID, @FixtureModelNoName, @FixtureDescription, @Location, @FixtureFolder, @FixtureImage, @CurrentStatus,
           @RequiresCalibration, @CalibrationID, @CalibrationFrequency, @CalEstTime, @RequiredPM, @PMFrequency, @PMEstTime, @PMResponsible, @Comments, @TestStationID, GETDATE(), @CreatedBy);", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)NullableString(eatonId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureModelNoName", modelNo ?? "");
            cmd.Parameters.AddWithValue("@FixtureDescription", (object)NullableString(fixtureDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableString(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureFolder", (object)NullableString(fixtureFolder) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureImage", (object)NullableString(fixtureImagePath) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableString(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableString(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableString(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalEstTime", (object)calEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableString(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMEstTime", (object)pmEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableString(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableString(comments) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@TestStationID", (object)testStationId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CreatedBy", (object)NullableString(GetCurrentENumber()) ?? DBNull.Value);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        // Change log: New Fixture item
        try
        {
            var recordName = !string.IsNullOrWhiteSpace(modelNo) ? modelNo : (eatonId ?? "Fixture Record");
            LogChangeEntry("dbo.Fixture_Inventory", eatonId ?? string.Empty, recordName, "Record Created", string.Empty, recordName, "Created");
        }
        catch { }

        // Create local file system folder for this equipment
        string folderPath = null;
        try
        {
            bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Fixture", eatonId);
            if (folderCreated)
            {
                folderPath = LocalFileSystemService.GetEquipmentFolderPath("Fixture", eatonId);
                
                // Update the database with the relative folder path (without server name for portability)
                if (!string.IsNullOrEmpty(folderPath))
                {
                    // Convert to relative path by removing the base storage path
                    string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                    string relativePath = folderPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                        ? folderPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                        : folderPath;
                    
                    // Ensure it starts with Storage/ for consistency
                    if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                    {
                        relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                    }
                    
                    using (SqlConnection conn = new SqlConnection(ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("UPDATE Fixture_Inventory SET FixtureFolder = @FolderPath WHERE EatonID = @EatonID", conn))
                    {
                        cmd.Parameters.AddWithValue("@FolderPath", relativePath);
                        cmd.Parameters.AddWithValue("@EatonID", eatonId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                ShowMessage("Fixture item created successfully. Document folder created.", "success");
            }
            else
            {
                string error = LocalFileSystemService.GetLastError();
                ShowMessage("Fixture item created successfully. Folder creation failed: " + error, "warning");
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Fixture item created successfully. (Folder error: " + ex.Message + ")", "warning");
        }
        
        ClearFormControls(phFormFields);
    }

    private void CreateHarnessItem()
    {
        string modelNo = GetText("txtHarnessModelNo");
        string harnessDesc = GetText("txtHarnessDescription");
        string location = GetSelectedText("ddlLocation");
        
        // Generate Eaton ID automatically based on harness model number
        string eatonId = GenerateHarnessEatonID(modelNo);
        
        string harnessFolder = GetText("txtHarnessFolder");
        string currentStatus = GetSelectedText("ddlCurrentStatus");
        bool requiresCal = GetChecked("chkRequiresCalibration");
        string calId = GetText("txtCalibrationID");
        string calFreq = GetSelectedText("ddlCalibrationFreq");
        bool requiredPM = GetChecked("chkRequiredPM");
        string pmFreq = GetSelectedText("ddlPMFreq");
        string pmResponsible = GetMultiSelectCsv("lstPMResponsible");
        string comments = GetText("txtComments");
        decimal? calEstTime = GetDecimal("txtCalEstimatedTime");
        decimal? pmEstTime = GetDecimal("txtPMEstimatedTime");

        string harnessImagePath = SaveUpload("fuHarnessImage", "Uploads/Images/Harnesses");
        int? testStationId = ResolveTestStationId(location);

       using (SqlConnection conn = new SqlConnection(ConnectionString))
        using (SqlCommand cmd = new SqlCommand(@"INSERT INTO Harness_Inventory 
            (EatonID, HarnessModelNo, HarnessDescription, Location, FixtureFolder, FixtureImage, CurrentStatus,
           RequiresCalibration, CalibrationID, CalibrationFrequency, CalibrationEstimatedTime, RequiredPM, PMFrequency, PMEstimatedTime, PMResponsible, Comments, TestStationID, CreatedDate, CreatedBy)
            VALUES (@EatonID, @HarnessModelNo, @HarnessDescription, @Location, @FixtureFolder, @FixtureImage, @CurrentStatus,
           @RequiresCalibration, @CalibrationID, @CalibrationFrequency, @CalEstTime, @RequiredPM, @PMFrequency, @PMEstTime, @PMResponsible, @Comments, @TestStationID, GETDATE(), @CreatedBy);", conn))
        {
            cmd.Parameters.AddWithValue("@EatonID", (object)NullableString(eatonId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@HarnessModelNo", modelNo ?? "");
            cmd.Parameters.AddWithValue("@HarnessDescription", (object)NullableString(harnessDesc) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Location", (object)NullableString(location) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureFolder", (object)NullableString(harnessFolder) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@FixtureImage", (object)NullableString(harnessImagePath) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CurrentStatus", (object)NullableString(currentStatus) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiresCalibration", requiresCal);
            cmd.Parameters.AddWithValue("@CalibrationID", (object)NullableString(calId) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalibrationFrequency", (object)NullableString(calFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CalEstTime", (object)calEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@RequiredPM", requiredPM);
            cmd.Parameters.AddWithValue("@PMFrequency", (object)NullableString(pmFreq) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMEstTime", (object)pmEstTime ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@PMResponsible", (object)NullableString(pmResponsible) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@Comments", (object)NullableString(comments) ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@TestStationID", (object)testStationId ?? DBNull.Value);
            cmd.Parameters.AddWithValue("@CreatedBy", (object)NullableString(GetCurrentENumber()) ?? DBNull.Value);
            conn.Open();
            cmd.ExecuteNonQuery();
        }

        // Change log: New Harness item
        try
        {
            var recordName = !string.IsNullOrWhiteSpace(modelNo) ? modelNo : (eatonId ?? "Harness Record");
            LogChangeEntry("dbo.Harness_Inventory", eatonId ?? string.Empty, recordName, "Record Created", string.Empty, recordName, "Created");
        }
        catch { }

        // Create local file system folder for this equipment
        string folderPath = null;
        try
        {
            bool folderCreated = LocalFileSystemService.CreateEquipmentFolder("Harness", eatonId);
            if (folderCreated)
            {
                folderPath = LocalFileSystemService.GetEquipmentFolderPath("Harness", eatonId);
                
                // Update the database with the relative folder path (without server name for portability)
                if (!string.IsNullOrEmpty(folderPath))
                {
                    // Convert to relative path by removing the base storage path
                    string baseStoragePath = HttpContext.Current.Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                    string relativePath = folderPath.StartsWith(baseStoragePath, StringComparison.OrdinalIgnoreCase) 
                        ? folderPath.Substring(baseStoragePath.Length).TrimStart('\\', '/') 
                        : folderPath;
                    
                    // Ensure it starts with Storage/ for consistency
                    if (!relativePath.StartsWith("Storage/", StringComparison.OrdinalIgnoreCase))
                    {
                        relativePath = "Storage/" + relativePath.TrimStart('/', '\\');
                    }
                    
                    using (SqlConnection conn = new SqlConnection(ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("UPDATE Harness_Inventory SET HarnessFolder = @FolderPath WHERE EatonID = @EatonID", conn))
                    {
                        cmd.Parameters.AddWithValue("@FolderPath", relativePath);
                        cmd.Parameters.AddWithValue("@EatonID", eatonId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                
                ShowMessage("Harness item created successfully. Document folder created.", "success");
            }
            else
            {
                string error = LocalFileSystemService.GetLastError();
                ShowMessage("Harness item created successfully. Folder creation failed: " + error, "warning");
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Harness item created successfully. (Folder error: " + ex.Message + ")", "warning");
        }
        
        ClearFormControls(phFormFields);
    }

    private void ShowMessage(string message, string type = "info")
    {
        // Map type names to banner classes
        string bannerType = "info";
        if (type == "success") bannerType = "success";
        else if (type == "error" || type == "warning") bannerType = "error";
        
        // Use client-side JavaScript to create a fixed banner at the top of the page
        string script = string.Format(@"
            (function() {{
                // Remove any existing banner
                var existing = document.querySelector('.msg-banner-notification');
                if (existing) existing.remove();
                
                // Create banner
                var banner = document.createElement('div');
                banner.className = 'msg-banner-notification msg-banner-{0}';
                banner.textContent = {1};
                banner.setAttribute('role', 'alert');
                
                // Add to page
                document.body.insertBefore(banner, document.body.firstChild);
                
                // Auto-dismiss after 8 seconds
                setTimeout(function() {{
                    banner.style.animation = 'slideUp 0.3s ease-out';
                    setTimeout(function() {{ banner.remove(); }}, 300);
                }}, 8000);
            }})();
        ", bannerType, Newtonsoft.Json.JsonConvert.SerializeObject(message));
        
        ScriptManager.RegisterStartupScript(this, this.GetType(), "showBannerMsg_" + Guid.NewGuid().ToString("N"), script, true);
    }

    private string GetCurrentENumber()
    {
        try
        {
            // Try common session keys used in the app
            object e1 = Session["ENumber"]; if (e1 != null) return e1.ToString();
            object e2 = Session["UserENumber"]; if (e2 != null) return e2.ToString();
            object e3 = Session["EN"]; if (e3 != null) return e3.ToString();
        }
        catch { }
        // Fallback to identity name (e.g., DOMAIN\\user) if available
        try { return Context != null && Context.User != null ? Context.User.Identity.Name : null; } catch { }
        return null;
    }

    #region Helpers: Input access, file save, lookups

    private string GetText(string id)
    {
        var ctl = FindControlRecursive(phFormFields, id) as TextBox;
        return ctl != null ? ctl.Text.Trim() : null;
    }

    private string GetSelectedText(string id)
    {
        var ddl = FindControlRecursive(phFormFields, id) as DropDownList;
        return ddl != null ? ddl.SelectedItem.Text.Trim() : null;
    }

    private string GetSelectedValue(string id)
    {
        var ddl = FindControlRecursive(phFormFields, id) as DropDownList;
        return ddl != null ? ddl.SelectedValue : null;
    }

    private bool GetChecked(string id)
    {
        // For raw HTML checkboxes (used for toggles), check the Request.Form
        var formValue = Request.Form[id];
        if (formValue != null)
        {
            // Checkbox posts "on" when checked, null when unchecked
            return formValue.Equals("on", StringComparison.OrdinalIgnoreCase);
        }
        
        // Fallback: try HtmlInputCheckBox
        var htmlChk = FindControlRecursive(phFormFields, id) as System.Web.UI.HtmlControls.HtmlInputCheckBox;
        if (htmlChk != null) return htmlChk.Checked;
        
        // Fallback: try standard CheckBox
        var chk = FindControlRecursive(phFormFields, id) as CheckBox;
        return chk != null && chk.Checked;
    }

    private decimal? GetDecimal(string id)
    {
        var ctl = FindControlRecursive(phFormFields, id) as TextBox;
        if (ctl != null && !string.IsNullOrWhiteSpace(ctl.Text))
        {
            decimal result;
            if (decimal.TryParse(ctl.Text.Trim(), out result))
            {
                return result;
            }
        }
        return null;
    }

    private Control FindControlRecursive(Control root, string id)
    {
        if (root.ID == id) return root;
        foreach (Control c in root.Controls)
        {
            var found = FindControlRecursive(c, id);
            if (found != null) return found;
        }
        return null;
    }

    private string NullableString(string value)
    {
        if (string.IsNullOrWhiteSpace(value)) return null;
        return value;
    }

    private string GetMultiSelectCsv(string baseName)
    {
        // Traverse dynamic controls and pick checked checkboxes whose ID starts with baseName + "_"
        List<string> labels = new List<string>();
        foreach (var cb in FindCheckBoxesWithPrefix(phFormFields, baseName + "_"))
        {
            if (cb.Checked)
            {
                string label = cb.InputAttributes["data-label"];
                if (!string.IsNullOrEmpty(label)) labels.Add(label);
            }
        }
        return labels.Count > 0 ? string.Join(", ", labels.ToArray()) : null;
    }

    private IEnumerable<CheckBox> FindCheckBoxesWithPrefix(Control root, string idPrefix)
    {
        List<CheckBox> found = new List<CheckBox>();
        FindCheckBoxesWithPrefixRecursive(root, idPrefix, found);
        return found;
    }

    private void FindCheckBoxesWithPrefixRecursive(Control root, string idPrefix, List<CheckBox> found)
    {
        foreach (Control c in root.Controls)
        {
            CheckBox cb = c as CheckBox;
            if (cb != null && cb.ID != null && cb.ID.StartsWith(idPrefix, StringComparison.Ordinal))
            {
                found.Add(cb);
            }
            if (c.HasControls())
            {
                FindCheckBoxesWithPrefixRecursive(c, idPrefix, found);
            }
        }
    }

    private string SaveUpload(string fileUploadId, string relativeFolder)
    {
        var fu = FindControlRecursive(phFormFields, fileUploadId) as FileUpload;
        if (fu == null || !fu.HasFile) return null;

        try
        {
            string folder = Server.MapPath("~/'" + relativeFolder.Replace("\\", "/").Trim('/').Replace("'", "") + "'");
            // Correct path join if the above has quotes; safer build:
            folder = Server.MapPath("~/") + relativeFolder.Replace("\\", "/").Trim('/');
            if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);

            string ext = Path.GetExtension(fu.FileName);
            string fileName = DateTime.Now.ToString("yyyyMMddHHmmssfff") + "_" + Path.GetFileNameWithoutExtension(fu.FileName).Replace(" ", "_") + ext;
            string full = Path.Combine(folder, fileName);
            fu.SaveAs(full);

            // return relative path for storage (consistent with folder paths)
            string relativePath = relativeFolder.Trim('/').Replace("\\", "/") + "/" + fileName;
            return relativePath;
        }
        catch
        {
            return null;
        }
    }

    private int? ResolveTestStationId(string locationText)
    {
        if (string.IsNullOrWhiteSpace(locationText)) return null;
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 TestStationID FROM TestStation_Bay WHERE StationSubLineCode = @code", conn))
            {
                cmd.Parameters.AddWithValue("@code", locationText);
                conn.Open();
                object obj = cmd.ExecuteScalar();
                if (obj != null && obj != DBNull.Value) return Convert.ToInt32(obj);
            }
        }
        catch { }
        return null;
    }

    private string ResolveATEName(string ateIdValue)
    {
        if (string.IsNullOrWhiteSpace(ateIdValue)) return null;
        int id;
        if (!int.TryParse(ateIdValue, out id)) return null;
        try
        {
            using (SqlConnection conn = new SqlConnection(ConnectionString))
            using (SqlCommand cmd = new SqlCommand("SELECT ATEName FROM ATE_Inventory WHERE ATEInventoryID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                object obj = cmd.ExecuteScalar();
                return obj != null && obj != DBNull.Value ? obj.ToString() : null;
            }
        }
        catch { return null; }
    }

    #endregion

    #region Change Log Helpers

    private void LogChangeEntry(string tableName, string recordId, string recordName, string fieldName, string oldValue, string newValue, string changeType)
    {
        try
        {
            using (var conn = new SqlConnection(ConnectionString))
            using (var cmd = new SqlCommand(@"INSERT INTO Change_Log (TableName, RecordID, RecordName, ChangedBy, ChangeDate, FieldName, OldValue, NewValue, ChangeType, CreatedDate)
                                             VALUES (@TableName, @RecordID, @RecordName, @ChangedBy, @ChangeDate, @FieldName, @OldValue, @NewValue, @ChangeType, @CreatedDate)", conn))
            {
                cmd.Parameters.AddWithValue("@TableName", tableName ?? string.Empty);
                // Change_Log.RecordID is INT; resolve the numeric ID via EatonID
                int recIdInt = ResolveNumericId(tableName, recordId);
                cmd.Parameters.AddWithValue("@RecordID", recIdInt);
                cmd.Parameters.AddWithValue("@RecordName", recordName ?? string.Empty);
                cmd.Parameters.AddWithValue("@ChangedBy", GetCurrentUserDisplay() ?? string.Empty);
                cmd.Parameters.AddWithValue("@ChangeDate", DateTime.Now);
                cmd.Parameters.AddWithValue("@FieldName", fieldName ?? string.Empty);
                cmd.Parameters.AddWithValue("@OldValue", oldValue ?? string.Empty);
                cmd.Parameters.AddWithValue("@NewValue", newValue ?? string.Empty);
                // Map to schema-allowed values
                var ct = changeType ?? string.Empty;
                if (string.Equals(ct, "New", StringComparison.OrdinalIgnoreCase)) ct = "Created";
                cmd.Parameters.AddWithValue("@ChangeType", ct);
                cmd.Parameters.AddWithValue("@CreatedDate", DateTime.Now);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private int ResolveNumericId(string tableName, string eatonId)
    {
        if (string.IsNullOrWhiteSpace(tableName) || string.IsNullOrWhiteSpace(eatonId)) return 0;
        string idCol = null;
        if (tableName.IndexOf("ATE_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "ATEInventoryID";
        else if (tableName.IndexOf("Asset_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "AssetID"; // fallback to AssetInventoryID if needed
        else if (tableName.IndexOf("Fixture_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "FixtureID";
        else if (tableName.IndexOf("Harness_Inventory", StringComparison.OrdinalIgnoreCase) >= 0) idCol = "HarnessID";
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
                if (tableName.IndexOf("Asset_Inventory", StringComparison.OrdinalIgnoreCase) >= 0)
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

    private string GetCurrentUserDisplay()
    {
        try
        {
            var name = Session["TED:FullName"] as string;
            if (!string.IsNullOrWhiteSpace(name)) return name;
            var en = Session["TED:ENumber"] as string ?? GetCurrentENumber();
            if (!string.IsNullOrWhiteSpace(en)) return en;
            return Context != null && Context.User != null ? Context.User.Identity.Name : "";
        }
        catch { return string.Empty; }
    }

    #endregion
}