// Last Modified: October 16, 2025 - 03:50 UTC - Fixed @AttachmentsPath parameter error on new report creation
using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Linq;
using System.Collections.Generic;
using System.Web;

public partial class TED_TroubleshootingDetails : Page
{
    // Returns the next available Troubleshooting_Log ID
    private int GetNextTroubleshootingId()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT ISNULL(MAX(ID), 0) + 1 FROM dbo.Troubleshooting_Log", conn))
            {
                conn.Open();
                object result = cmd.ExecuteScalar();
                return Convert.ToInt32(result);
            }
        }
        catch
        {
            return 1;
        }
    }
    private int? TroubleshootingID
    {
        get
        {
            if (ViewState["TroubleshootingID"] != null)
                return (int)ViewState["TroubleshootingID"];
            
            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int id;
                if (int.TryParse(Request.QueryString["id"], out id))
                    return id;
            }
            return null;
        }
        set { ViewState["TroubleshootingID"] = value; }
    }

    private bool IsNewMode
    {
        get { return Request.QueryString["mode"] == "new" || TroubleshootingID == null; }
    }
    
    protected bool IsNewModePublic
    {
        get { return IsNewMode; }
    }
    
    private bool CanEdit
    {
        get
        {
            if (Session["TED:UserCategory"] != null)
            {
                string userCategory = Session["TED:UserCategory"].ToString();
                System.Diagnostics.Debug.WriteLine("TroubleshootingDetails - User Category: " + userCategory);
                return userCategory == "Admin" || userCategory == "Test Engineering";
            }
            System.Diagnostics.Debug.WriteLine("TroubleshootingDetails - No user category found in session");
            return false;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Handle action=viewFirst - redirect to first available troubleshooting log
            if (Request.QueryString["action"] == "viewFirst")
            {
                RedirectToFirstTroubleshootingLog();
                return;
            }
            
            // Handle delete attachment request
            if (!string.IsNullOrEmpty(Request.QueryString["deleteAttachment"]) && TroubleshootingID.HasValue)
            {
                DeleteAttachment(Request.QueryString["deleteAttachment"], TroubleshootingID.Value);
                Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}", TroubleshootingID.Value));
                return;
            }
            
            LoadLocationDropdown();
            LoadEquipmentDropdowns();
            LoadUsersDropdown();
            LoadReportedByDropdown();
            LoadTroubleshootingDropdown();
            
            if (IsNewMode)
            {
                SetupNewMode();
                txtTroubleshootingID.Enabled = false;
            }
            else if (TroubleshootingID.HasValue)
            {
                LoadTroubleshootingData(TroubleshootingID.Value);
                txtTroubleshootingID.Enabled = false;
                ddlLocation.Enabled = false;
            }
            else
            {
                ShowBannerMessage("Invalid troubleshooting log ID.", "error");
            }

            // Show banner notification if redirected with msg
            string msg = Request.QueryString["msg"];
            if (msg == "created")
            {
                ShowBannerMessage("Troubleshooting log created successfully!", "success");
            }
            else if (msg == "updated")
            {
                ShowBannerMessage("Changes saved successfully!", "success");
            }
            
            // Apply permissions AFTER loading data
            ApplyPermissions();
        }
    }
    
    private void LoadLocationDropdown()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT DISTINCT StationSubLineCode FROM dbo.TestStation_Bay WHERE StationSubLineCode IS NOT NULL AND StationSubLineCode != '' ORDER BY StationSubLineCode", conn))
            {
                conn.Open();
                ddlLocation.Items.Clear();
                ddlLocation.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string location = reader["StationSubLineCode"].ToString();
                        ddlLocation.Items.Add(new ListItem(location, location));
                    }
                }
            }

            // For existing records, ensure the current Location value is in the dropdown
            if (!IsNewMode && TroubleshootingID.HasValue)
            {
                try
                {
                    using (var conn = new SqlConnection(cs))
                    using (var cmd = new SqlCommand("SELECT Location FROM dbo.Troubleshooting_Log WHERE ID = @ID", conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", TroubleshootingID.Value);
                        conn.Open();
                        var result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            string currentLocation = result.ToString();
                            if (!string.IsNullOrWhiteSpace(currentLocation) && ddlLocation.Items.FindByValue(currentLocation) == null)
                            {
                                ddlLocation.Items.Add(new ListItem(currentLocation, currentLocation));
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine("Error loading current location: " + ex.Message);
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadLocationDropdown error: " + ex.Message);
        }
    }
    
    private void LoadEquipmentDropdowns()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            // Load ATE dropdown - Format: "EatonID | ATEName"
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT ATEInventoryID, EatonID, ATEName FROM dbo.ATE_Inventory WHERE IsActive = 1 ORDER BY EatonID, ATEName", conn))
            {
                conn.Open();
                ddlAffectedATE.Items.Clear();
                ddlAffectedATE.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string ateInventoryId = reader["ATEInventoryID"].ToString();
                        string eatonId = reader["EatonID"] != DBNull.Value ? reader["EatonID"].ToString() : "";
                        string ateName = reader["ATEName"].ToString();
                        string displayText = string.IsNullOrEmpty(eatonId) ? ateName : string.Format("{0}  |  {1}", eatonId, ateName);
                        string value = eatonId + "|" + ateName;
                        ddlAffectedATE.Items.Add(new ListItem(displayText, value));
                    }
                }
            }
            
            // Load Asset/Equipment dropdown - Format: "EatonID | ModelNo. | Location"
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT AssetID, EatonID, ModelNo, DeviceName, Location FROM dbo.Asset_Inventory WHERE IsActive = 1 ORDER BY EatonID, DeviceName", conn))
            {
                conn.Open();
                ddlAffectedEquipment.Items.Clear();
                ddlAffectedEquipment.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string assetId = reader["AssetID"].ToString();
                        string eatonId = reader["EatonID"] != DBNull.Value ? reader["EatonID"].ToString() : "";
                        string modelNo = reader["ModelNo"] != DBNull.Value ? reader["ModelNo"].ToString() : "";
                        string location = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "";
                        string deviceName = reader["DeviceName"].ToString();
                        
                        string displayText;
                        if (!string.IsNullOrEmpty(eatonId))
                            displayText = string.Format("{0}  |  {1}  |  {2}", eatonId, modelNo, location);
                        else
                            displayText = deviceName;
                            
                        string value = eatonId + "|" + deviceName;
                        ddlAffectedEquipment.Items.Add(new ListItem(displayText, value));
                    }
                }
            }
            
            // Load Fixture dropdown - Format: "EatonID | FixtureModelNoName"
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT FixtureID, EatonID, FixtureModelNoName FROM dbo.Fixture_Inventory WHERE IsActive = 1 ORDER BY EatonID, FixtureModelNoName", conn))
            {
                conn.Open();
                ddlAffectedFixture.Items.Clear();
                ddlAffectedFixture.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string fixtureId = reader["FixtureID"].ToString();
                        string eatonId = reader["EatonID"] != DBNull.Value ? reader["EatonID"].ToString() : "";
                        string fixtureName = reader["FixtureModelNoName"].ToString();
                        string displayText = string.IsNullOrEmpty(eatonId) ? fixtureName : string.Format("{0}  |  {1}", eatonId, fixtureName);
                        string value = eatonId + "|" + fixtureName;
                        ddlAffectedFixture.Items.Add(new ListItem(displayText, value));
                    }
                }
            }
            
            // Load Harness dropdown - Format: "EatonID | HarnessModelNo"
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT HarnessID, EatonID, HarnessModelNo FROM dbo.Harness_Inventory WHERE IsActive = 1 ORDER BY EatonID, HarnessModelNo", conn))
            {
                conn.Open();
                ddlAffectedHarness.Items.Clear();
                ddlAffectedHarness.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string harnessId = reader["HarnessID"].ToString();
                        string eatonId = reader["EatonID"] != DBNull.Value ? reader["EatonID"].ToString() : "";
                        string harnessName = reader["HarnessModelNo"].ToString();
                        string displayText = string.IsNullOrEmpty(eatonId) ? harnessName : string.Format("{0}  |  {1}", eatonId, harnessName);
                        string value = eatonId + "|" + harnessName;
                        ddlAffectedHarness.Items.Add(new ListItem(displayText, value));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDropdowns error: " + ex.Message);
        }
    }
    
    private void LoadUsersDropdown()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT UserID, FullName FROM dbo.Users WHERE IsActive = 1 ORDER BY FullName", conn))
            {
                conn.Open();
                ddlResolvedBy.Items.Clear();
                ddlResolvedBy.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string fullName = reader["FullName"].ToString();
                        ddlResolvedBy.Items.Add(new ListItem(fullName, fullName));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadUsersDropdown error: " + ex.Message);
        }
    }
    
    private void LoadReportedByDropdown()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT UserID, FullName FROM dbo.Users WHERE IsActive = 1 ORDER BY FullName", conn))
            {
                conn.Open();
                ddlReportedBy.Items.Clear();
                ddlReportedBy.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string fullName = reader["FullName"].ToString();
                        ddlReportedBy.Items.Add(new ListItem(fullName, fullName));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadReportedByDropdown error: " + ex.Message);
        }
    }
    
    private void LoadTroubleshootingDropdown()
    {
        try
        {
            // Always make dropdown visible and load data (needed for navigation from New mode)
            divTSSelector.Visible = !IsNewMode;  // Keep hidden in new mode for cleaner UI
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 100 
                    ID, 
                    Location, 
                    CONVERT(VARCHAR(10), ReportedDateTime, 101) AS ReportedDate,
                    Status
                FROM dbo.Troubleshooting_Log
                ORDER BY ID DESC", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    ddlTroubleshootingSelector.Items.Clear();
                    // No longer adding "Select Troubleshooting ID..." option - only show existing records
                    
                    while (reader.Read())
                    {
                        int id = Convert.ToInt32(reader["ID"]);
                        string location = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "N/A";
                        string date = reader["ReportedDate"] != DBNull.Value ? reader["ReportedDate"].ToString() : "";
                        string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";
                        
                        string displayText = string.Format("#{0} - {1} ({2}) - {3}", id, location, date, status);
                        ddlTroubleshootingSelector.Items.Add(new ListItem(displayText, id.ToString()));
                    }
                }
            }
            
            // Set the selected value to current ID
            if (TroubleshootingID.HasValue && ddlTroubleshootingSelector.Items.FindByValue(TroubleshootingID.Value.ToString()) != null)
            {
                ddlTroubleshootingSelector.SelectedValue = TroubleshootingID.Value.ToString();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadTroubleshootingDropdown error: " + ex.Message);
            divTSSelector.Visible = false;
        }
    }
    
    private void RedirectToFirstTroubleshootingLog()
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT TOP 1 ID FROM dbo.Troubleshooting_Log ORDER BY ID ASC", conn))
            {
                conn.Open();
                var result = cmd.ExecuteScalar();
                
                System.Diagnostics.Debug.WriteLine("RedirectToFirstTroubleshootingLog - Result: " + (result != null ? result.ToString() : "NULL"));
                
                if (result != null && result != DBNull.Value)
                {
                    int firstId = Convert.ToInt32(result);
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstTroubleshootingLog - Redirecting to ID: " + firstId);
                    Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}", firstId));
                    return;
                }
                else
                {
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstTroubleshootingLog - No records found, staying on new mode");
                }
            }
            
            // No troubleshooting logs exist yet, show message and stay on New Issue Report page
            ShowMessage("No troubleshooting logs exist yet. Create the first one!", "info");
        }
        catch (Exception ex)
        {
            // Log the error for debugging
            System.Diagnostics.Debug.WriteLine("RedirectToFirstTroubleshootingLog error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack trace: " + ex.StackTrace);
            
            // Show error message to user
            ShowMessage("Error loading troubleshooting logs: " + ex.Message, "error");
        }
    }
    
    protected void ddlTroubleshootingSelector_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlTroubleshootingSelector.SelectedValue))
        {
            Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}", ddlTroubleshootingSelector.SelectedValue));
        }
    }

    private void SetupNewMode()
    {
        litPageTitle.Text = "New Troubleshooting Report";
        litPageSubtitle.Text = "Create a new troubleshooting log entry";
        txtReportedDateTime.Text = "";  // Leave blank instead of pre-filling with current time

        // Don't pre-fill reporter name - leave blank for user to select
        // Removed: Pre-fill reporter name from session

        btnDelete.Visible = false;
        btnSave.Text = "<span aria-hidden='true' class='icon'><svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M12 5v14'/><path d='M5 12h14'/></svg></span><span class='txt'>Create Log</span>";

        // Show no attachments message for new records
        DisplayAttachments("");
        txtTroubleshootingID.Enabled = false;
        // Always generate ID_Location string if location is available
        string location = ddlLocation.SelectedValue;
        int nextId = GetNextTroubleshootingId();
        if (!string.IsNullOrWhiteSpace(location))
        {
            txtTroubleshootingID.Text = string.Format("{0}_{1}", nextId, location);
        }
        
        // Clear hidden field for new records
        hfLocation.Value = "";
    }
    
    private void ApplyPermissions()
    {
        bool canEdit = CanEdit;
        
        // Disable all form controls if user doesn't have edit permission and not in new mode
        if (!canEdit && !IsNewMode)
        {
            // Disable all input controls
            ddlLocation.Enabled = false;
            txtSymptom.Enabled = false;
            ddlReportedBy.Enabled = false;
            txtReportedDateTime.Enabled = false;
            txtTroubleshootingSteps.Enabled = false;
            txtSolution.Enabled = false;
            ddlStatus.Enabled = false;
            ddlPriority.Enabled = false;
            ddlIssueClassification.Enabled = false;
            ddlIssueSubclassification.Enabled = false;
            txtRootCause.Enabled = false;
            txtPreventiveAction.Enabled = false;
            ddlAffectedATE.Enabled = false;
            ddlAffectedEquipment.Enabled = false;
            ddlAffectedFixture.Enabled = false;
            ddlAffectedHarness.Enabled = false;
            chkIsRepeat.Disabled = true; // HtmlInputCheckBox uses Disabled property, not Enabled
            txtDowntimeHours.Enabled = false;
            ddlImpactLevel.Enabled = false;
            txtResolvedDateTime.Enabled = false;
            ddlResolvedBy.Enabled = false;
            txtAdditionalComments.Enabled = false;
            fileUpload.Enabled = false;
            
            // Hide action buttons
            btnSave.Visible = false;
            btnDelete.Visible = false;
        }
        else if (canEdit && !IsNewMode)
        {
            // Explicitly enable controls for users with edit permission
            ddlLocation.Enabled = true;
            txtSymptom.Enabled = true;
            ddlReportedBy.Enabled = true;
            txtReportedDateTime.Enabled = true;
            txtTroubleshootingSteps.Enabled = true;
            txtSolution.Enabled = true;
            ddlStatus.Enabled = true;
            ddlPriority.Enabled = true;
            ddlIssueClassification.Enabled = true;
            ddlIssueSubclassification.Enabled = true;
            txtRootCause.Enabled = true;
            txtPreventiveAction.Enabled = true;
            ddlAffectedATE.Enabled = true;
            ddlAffectedEquipment.Enabled = true;
            ddlAffectedFixture.Enabled = true;
            ddlAffectedHarness.Enabled = true;
            chkIsRepeat.Disabled = false;
            txtDowntimeHours.Enabled = true;
            ddlImpactLevel.Enabled = true;
            txtResolvedDateTime.Enabled = true;
            ddlResolvedBy.Enabled = true;
            txtAdditionalComments.Enabled = true;
            fileUpload.Enabled = true;
            
            // Show action buttons
            btnSave.Visible = true;
            btnDelete.Visible = true;
        }
        // For new mode (IsNewMode == true), controls are already enabled by default
    }

    private void LoadTroubleshootingData(int id)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    ID,
                    Location,
                    Symptom,
                    ReportedBy,
                    ReportedDateTime,
                    TroubleshootingStepsDescription,
                    SolutionApplied,
                    Status,
                    Priority,
                    IssueClassification,
                    IssueSubclassification,
                    ResolvedDateTime,
                    ResolvedBy,
                    RootCause,
                    PreventiveAction,
                    AdditionalComments,
                    AffectedATE,
                    AffectedEquipment,
                    AffectedFixture,
                    AffectedHarness,
                    IsRepeat,
                    DowntimeHours,
                    ImpactLevel,
                    CreatedDate,
                    AttachmentsPath,
                    TroubleshootingID
                FROM dbo.Troubleshooting_Log
                WHERE ID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                    string troubleshootingIdValue = reader["TroubleshootingID"] != DBNull.Value ? reader["TroubleshootingID"].ToString() : "";
                    txtTroubleshootingID.Text = !string.IsNullOrWhiteSpace(troubleshootingIdValue) ? troubleshootingIdValue : (reader["ID"] != DBNull.Value ? reader["ID"].ToString() : "N/A");
                        
                        string location = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "";
                        if (!string.IsNullOrEmpty(location) && ddlLocation.Items.FindByValue(location) != null)
                            ddlLocation.SelectedValue = location;
                        
                        // Store location in hidden field for existing records
                        hfLocation.Value = location;
                        
                        txtSymptom.Text = reader["Symptom"] != DBNull.Value ? reader["Symptom"].ToString() : "";
                        
                        string reportedBy = reader["ReportedBy"] != DBNull.Value ? reader["ReportedBy"].ToString() : "";
                        if (!string.IsNullOrEmpty(reportedBy) && ddlReportedBy.Items.FindByValue(reportedBy) != null)
                            ddlReportedBy.SelectedValue = reportedBy;
                        
                        if (reader["ReportedDateTime"] != DBNull.Value)
                        {
                            DateTime reportedDate = Convert.ToDateTime(reader["ReportedDateTime"]);
                            txtReportedDateTime.Text = reportedDate.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        txtTroubleshootingSteps.Text = reader["TroubleshootingStepsDescription"] != DBNull.Value ? reader["TroubleshootingStepsDescription"].ToString() : "";
                        txtSolution.Text = reader["SolutionApplied"] != DBNull.Value ? reader["SolutionApplied"].ToString() : "";
                        txtRootCause.Text = reader["RootCause"] != DBNull.Value ? reader["RootCause"].ToString() : "";
                        txtPreventiveAction.Text = reader["PreventiveAction"] != DBNull.Value ? reader["PreventiveAction"].ToString() : "";
                        txtAdditionalComments.Text = reader["AdditionalComments"] != DBNull.Value ? reader["AdditionalComments"].ToString() : "";
                        
                        // Equipment fields - Find dropdown items by EatonID (stored in the columns)
                        
                        string affectedATE = reader["AffectedATE"] != DBNull.Value ? reader["AffectedATE"].ToString() : "";
                        if (!string.IsNullOrEmpty(affectedATE))
                        {
                            var ateItem = ddlAffectedATE.Items.Cast<ListItem>().FirstOrDefault(li => li.Value.Contains("|") && li.Value.Split('|')[0] == affectedATE);
                            if (ateItem != null)
                                ddlAffectedATE.SelectedValue = ateItem.Value;
                        }
                        
                        string affectedEquipment = reader["AffectedEquipment"] != DBNull.Value ? reader["AffectedEquipment"].ToString() : "";
                        if (!string.IsNullOrEmpty(affectedEquipment))
                        {
                            var equipmentItem = ddlAffectedEquipment.Items.Cast<ListItem>().FirstOrDefault(li => li.Value.Contains("|") && li.Value.Split('|')[0] == affectedEquipment);
                            if (equipmentItem != null)
                                ddlAffectedEquipment.SelectedValue = equipmentItem.Value;
                        }
                        
                        string affectedFixture = reader["AffectedFixture"] != DBNull.Value ? reader["AffectedFixture"].ToString() : "";
                        if (!string.IsNullOrEmpty(affectedFixture))
                        {
                            var fixtureItem = ddlAffectedFixture.Items.Cast<ListItem>().FirstOrDefault(li => li.Value.Contains("|") && li.Value.Split('|')[0] == affectedFixture);
                            if (fixtureItem != null)
                                ddlAffectedFixture.SelectedValue = fixtureItem.Value;
                        }
                        
                        string affectedHarness = reader["AffectedHarness"] != DBNull.Value ? reader["AffectedHarness"].ToString() : "";
                        if (!string.IsNullOrEmpty(affectedHarness))
                        {
                            var harnessItem = ddlAffectedHarness.Items.Cast<ListItem>().FirstOrDefault(li => li.Value.Contains("|") && li.Value.Split('|')[0] == affectedHarness);
                            if (harnessItem != null)
                                ddlAffectedHarness.SelectedValue = harnessItem.Value;
                        }
                        
                        // Subclassification
                        string subclassification = reader["IssueSubclassification"] != DBNull.Value ? reader["IssueSubclassification"].ToString() : "";
                        if (!string.IsNullOrEmpty(subclassification) && ddlIssueSubclassification.Items.FindByValue(subclassification) != null)
                            ddlIssueSubclassification.SelectedValue = subclassification;
                        
                        // Status and Priority
                        string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "Open";
                        if (ddlStatus.Items.FindByValue(status) != null)
                            ddlStatus.SelectedValue = status;
                        
                        string priority = reader["Priority"] != DBNull.Value ? reader["Priority"].ToString() : "Medium";
                        if (ddlPriority.Items.FindByValue(priority) != null)
                            ddlPriority.SelectedValue = priority;
                        
                        string classification = reader["IssueClassification"] != DBNull.Value ? reader["IssueClassification"].ToString() : "";
                        if (!string.IsNullOrEmpty(classification) && ddlIssueClassification.Items.FindByValue(classification) != null)
                            ddlIssueClassification.SelectedValue = classification;
                        
                        // Impact Level
                        string impactLevel = reader["ImpactLevel"] != DBNull.Value ? reader["ImpactLevel"].ToString() : "";
                        if (!string.IsNullOrEmpty(impactLevel) && ddlImpactLevel.Items.FindByValue(impactLevel) != null)
                            ddlImpactLevel.SelectedValue = impactLevel;
                        
                        // Metrics
                        if (reader["DowntimeHours"] != DBNull.Value)
                            txtDowntimeHours.Text = reader["DowntimeHours"].ToString();
                        
                        if (reader["IsRepeat"] != DBNull.Value)
                            chkIsRepeat.Checked = Convert.ToBoolean(reader["IsRepeat"]);
                        
                        if (reader["ResolvedDateTime"] != DBNull.Value)
                        {
                            DateTime resolvedDate = Convert.ToDateTime(reader["ResolvedDateTime"]);
                            txtResolvedDateTime.Text = resolvedDate.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        string resolvedBy = reader["ResolvedBy"] != DBNull.Value ? reader["ResolvedBy"].ToString() : "";
                        if (!string.IsNullOrEmpty(resolvedBy) && ddlResolvedBy.Items.FindByValue(resolvedBy) != null)
                            ddlResolvedBy.SelectedValue = resolvedBy;
                        
                        if (reader["CreatedDate"] != DBNull.Value)
                        {
                            DateTime createdDate = Convert.ToDateTime(reader["CreatedDate"]);
                            txtCreatedDate.Text = createdDate.ToString("yyyy-MM-dd HH:mm:ss");
                        }
                        
                        litPageTitle.Text = string.Format("Troubleshooting Log #{0}", id);
                        litPageSubtitle.Text = string.Format("Location: {0} | Status: {1}", 
                            reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "N/A", 
                            status);
                        
                        // Display attachments
                        string attachmentsPath = reader["AttachmentsPath"] != DBNull.Value ? reader["AttachmentsPath"].ToString() : "";
                        DisplayAttachments(attachmentsPath);
                        
                        // Show delete button for existing records
                        btnDelete.Visible = true;
                            txtTroubleshootingID.Enabled = false;
                            ddlLocation.Enabled = false;
                            ddlLocation.Attributes["disabled"] = "disabled";
                    }
                    else
                    {
                        ShowMessage("Troubleshooting log not found.", "error");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading troubleshooting data: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("LoadTroubleshootingData error: " + ex.Message);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        // Check permissions for editing (allow new records or edit permission)
        if (!IsNewMode && !CanEdit)
        {
            ShowMessage("You do not have permission to edit troubleshooting logs.", "error");
            return;
        }
        
        try
        {
            // List of mandatory fields and their labels
            var mandatoryFields = new List<KeyValuePair<string, string>>();
            
            // Location is only mandatory for new records, not for existing ones (since it's disabled)
            if (IsNewMode)
            {
                mandatoryFields.Add(new KeyValuePair<string, string>("ddlLocation", "Location"));
            }
            
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlStatus", "Status"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtSymptom", "Symptom/Issue Description"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlPriority", "Priority"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlIssueClassification", "Issue Classification"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlIssueSubclassification", "Issue Subclassification"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlReportedBy", "Reported By"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtReportedDateTime", "Reported Date/Time"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlImpactLevel", "Impact Level"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtDowntimeHours", "Downtime Hours"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtTroubleshootingSteps", "Troubleshooting Steps / Description"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtSolution", "Solution Applied"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtRootCause", "Root Cause Analysis"));

            var missingFields = new List<string>();

            // Check each field
            foreach (KeyValuePair<string, string> field in mandatoryFields)
            {
                var control = FindControlRecursive(Page, field.Key);
                DropDownList ddl = control as DropDownList;
                TextBox txt = control as TextBox;
                if (ddl != null)
                {
                    // Special handling for Location - use hidden field for existing records
                    if (field.Key == "ddlLocation" && !IsNewMode)
                    {
                        if (string.IsNullOrWhiteSpace(hfLocation.Value))
                            missingFields.Add(field.Value);
                    }
                    else if (string.IsNullOrWhiteSpace(ddl.SelectedValue))
                    {
                        missingFields.Add(field.Value);
                    }
                }
                else if (txt != null)
                {
                    if (string.IsNullOrWhiteSpace(txt.Text))
                        missingFields.Add(field.Value);
                }
            }

            if (missingFields.Count > 0)
            {
                string missingText = string.Format("Please fill the following required fields: {0}", string.Join(", ", missingFields));
                ShowBannerMessage(missingText, "error");
                return;
            }

            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

            if (IsNewMode)
            {
                // Ensure TroubleshootingID is set before insert
                string location = ddlLocation.SelectedValue;
                int nextId = GetNextTroubleshootingId();
                if (!string.IsNullOrWhiteSpace(location))
                {
                    txtTroubleshootingID.Text = string.Format("{0}_{1}", nextId, location);
                }
                
                // Insert new record first
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.Troubleshooting_Log (
                        Location, Symptom, ReportedBy, ReportedDateTime,
                        TroubleshootingStepsDescription, SolutionApplied, Status,
                        Priority, IssueClassification, IssueSubclassification,
                        ResolvedDateTime, ResolvedBy, RootCause, PreventiveAction,
                        AdditionalComments, AffectedATE, AffectedEquipment, AffectedFixture,
                        AffectedHarness,
                        IsRepeat, DowntimeHours, ImpactLevel,
                        TroubleshootingID
                    ) VALUES (
                        @Location, @Symptom, @ReportedBy, @ReportedDateTime,
                        @Description, @Solution, @Status,
                        @Priority, @Classification, @Subclassification,
                        @ResolvedDateTime, @ResolvedBy, @RootCause, @PreventiveAction,
                        @AdditionalComments, @AffectedATE, @AffectedEquipment, @AffectedFixture,
                        @AffectedHarness,
                        @IsRepeat, @DowntimeHours, @ImpactLevel,
                        @TroubleshootingID
                    ); SELECT SCOPE_IDENTITY();", conn))
                {
                    AddParameters(cmd);
                    
                    conn.Open();
                    int newId = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    // Create local file system folder for this troubleshooting case with correct ID
                    try
                    {
                        if (!string.IsNullOrWhiteSpace(location))
                        {
                            bool folderCreated = LocalFileSystemService.CreateTroubleshootingFolder(newId.ToString(), location);
                            if (!folderCreated)
                            {
                                string error = LocalFileSystemService.GetLastError();
                                System.Diagnostics.Debug.WriteLine("Troubleshooting folder creation failed: " + error);
                            }
                        }
                    }
                    catch (Exception folderEx)
                    {
                        System.Diagnostics.Debug.WriteLine("Troubleshooting folder error: " + folderEx.Message);
                    }
                    
                    // Handle file uploads for new record with correct ID and location
                    string attachmentsPath = "";
                    if (fileUpload.HasFiles)
                    {
                        attachmentsPath = HandleFileUploads(newId, location);
                        
                        // Update attachments path if files were uploaded
                        if (!string.IsNullOrEmpty(attachmentsPath))
                        {
                            using (var updateCmd = new SqlCommand("UPDATE dbo.Troubleshooting_Log SET AttachmentsPath = @AttachmentsPath WHERE ID = @ID", conn))
                            {
                                updateCmd.Parameters.AddWithValue("@ID", newId);
                                updateCmd.Parameters.AddWithValue("@AttachmentsPath", attachmentsPath);
                                updateCmd.ExecuteNonQuery();
                            }
                        }
                    }
                    
                    // Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}&msg=created", newId));
                    ShowMessage("Record created successfully! ID: " + newId, "success");
                    Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}&msg=created", newId));
                }
            }
            else if (TroubleshootingID.HasValue)
            {
                // Get the location for file uploads
                string location = string.IsNullOrWhiteSpace(hfLocation.Value) ? ddlLocation.SelectedValue : hfLocation.Value;
                
                // Ensure folder exists before uploading files
                if (!string.IsNullOrWhiteSpace(location))
                {
                    bool folderExists = LocalFileSystemService.CreateTroubleshootingFolder(TroubleshootingID.Value.ToString(), location);
                    if (!folderExists)
                    {
                        string error = LocalFileSystemService.GetLastError();
                        System.Diagnostics.Debug.WriteLine("Troubleshooting folder creation failed for existing record: " + error);
                        ShowMessage("Warning: Could not create troubleshooting folder. " + error, "warning");
                    }
                }
                
                // Handle file uploads for existing record
                string attachmentsPath = HandleFileUploads(TroubleshootingID.Value, location);
                
                // Update existing record
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.Troubleshooting_Log SET
                        Location = @Location,
                        Symptom = @Symptom,
                        ReportedBy = @ReportedBy,
                        ReportedDateTime = @ReportedDateTime,
                        TroubleshootingStepsDescription = @Description,
                        SolutionApplied = @Solution,
                        Status = @Status,
                        Priority = @Priority,
                        IssueClassification = @Classification,
                        IssueSubclassification = @Subclassification,
                        ResolvedDateTime = @ResolvedDateTime,
                        ResolvedBy = @ResolvedBy,
                        RootCause = @RootCause,
                        PreventiveAction = @PreventiveAction,
                        AdditionalComments = @AdditionalComments,
                        AffectedATE = @AffectedATE,
                        AffectedEquipment = @AffectedEquipment,
                        AffectedFixture = @AffectedFixture,
                        AffectedHarness = @AffectedHarness,
                        IsRepeat = @IsRepeat,
                        DowntimeHours = @DowntimeHours,
                        ImpactLevel = @ImpactLevel,
                        AttachmentsPath = @AttachmentsPath
                    WHERE ID = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", TroubleshootingID.Value);
                    cmd.Parameters.AddWithValue("@AttachmentsPath", string.IsNullOrEmpty(attachmentsPath) ? (object)DBNull.Value : attachmentsPath);
                    AddParameters(cmd);
                    
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();
                    
                    if (rowsAffected > 0)
                    {
                        // Redirect with success message
                        // Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}&msg=updated", TroubleshootingID.Value));
                        ShowMessage("Record updated successfully!", "success");
                        Response.Redirect(string.Format("TroubleshootingDetails.aspx?id={0}&msg=updated", TroubleshootingID.Value));
                    }
                    else
                    {
                        ShowBannerMessage("No changes were made.", "info");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowBannerMessage("Error saving troubleshooting log: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("btnSave_Click error: " + ex.Message);
        }

    }

    // Recursively find control by ID
    private Control FindControlRecursive(Control root, string id)
    {
        if (root.ID == id)
            return root;
        foreach (Control child in root.Controls)
        {
            var found = FindControlRecursive(child, id);
            if (found != null)
                return found;
        }
        return null;
    }

    // Modern top banner notification
    private void ShowBannerMessage(string message, string type = "info")
    {
        // Properly escape the message and type for JavaScript
        string safeMessage = message.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "\\\"").Replace("\n", "\\n").Replace("\r", "\\r");
        string safeType = type.Replace("\\", "\\\\").Replace("'", "\\'").Replace("\"", "\\\"");
        string script = "window.showBannerMsg('" + safeMessage + "', '" + safeType + "');";

        // Try both ScriptManager and ClientScript for reliability
        if (ScriptManager.GetCurrent(Page) != null)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showBannerMsg", script, true);
        }
        Page.ClientScript.RegisterStartupScript(this.GetType(), "showBannerMsgFallback", script, true);
    }
    private void AddParameters(SqlCommand cmd)
    {
        // For Location, use hidden field value for existing records (since dropdown is disabled)
        string locationValue = string.IsNullOrWhiteSpace(hfLocation.Value) ? ddlLocation.SelectedValue : hfLocation.Value;
        cmd.Parameters.AddWithValue("@Location", string.IsNullOrWhiteSpace(locationValue) ? (object)DBNull.Value : locationValue);
        cmd.Parameters.AddWithValue("@Symptom", string.IsNullOrWhiteSpace(txtSymptom.Text) ? (object)DBNull.Value : txtSymptom.Text.Trim());
        cmd.Parameters.AddWithValue("@ReportedBy", string.IsNullOrWhiteSpace(ddlReportedBy.SelectedValue) ? (object)DBNull.Value : ddlReportedBy.SelectedValue);
        
        DateTime reportedDateTime;
        if (DateTime.TryParse(txtReportedDateTime.Text, out reportedDateTime))
            cmd.Parameters.AddWithValue("@ReportedDateTime", reportedDateTime);
        else
            cmd.Parameters.AddWithValue("@ReportedDateTime", DateTime.Now);
        
        cmd.Parameters.AddWithValue("@Description", string.IsNullOrWhiteSpace(txtTroubleshootingSteps.Text) ? (object)DBNull.Value : txtTroubleshootingSteps.Text.Trim());
        cmd.Parameters.AddWithValue("@Solution", string.IsNullOrWhiteSpace(txtSolution.Text) ? (object)DBNull.Value : txtSolution.Text.Trim());
        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
        cmd.Parameters.AddWithValue("@Priority", ddlPriority.SelectedValue);
        cmd.Parameters.AddWithValue("@Classification", string.IsNullOrWhiteSpace(ddlIssueClassification.SelectedValue) ? (object)DBNull.Value : ddlIssueClassification.SelectedValue);
        cmd.Parameters.AddWithValue("@Subclassification", string.IsNullOrWhiteSpace(ddlIssueSubclassification.SelectedValue) ? (object)DBNull.Value : ddlIssueSubclassification.SelectedValue);
        
        DateTime resolvedDateTime;
        if (!string.IsNullOrWhiteSpace(txtResolvedDateTime.Text) && DateTime.TryParse(txtResolvedDateTime.Text, out resolvedDateTime))
            cmd.Parameters.AddWithValue("@ResolvedDateTime", resolvedDateTime);
        else
            cmd.Parameters.AddWithValue("@ResolvedDateTime", DBNull.Value);
        
        cmd.Parameters.AddWithValue("@ResolvedBy", string.IsNullOrWhiteSpace(ddlResolvedBy.SelectedValue) ? (object)DBNull.Value : ddlResolvedBy.SelectedValue);
        cmd.Parameters.AddWithValue("@RootCause", string.IsNullOrWhiteSpace(txtRootCause.Text) ? (object)DBNull.Value : txtRootCause.Text.Trim());
        cmd.Parameters.AddWithValue("@PreventiveAction", string.IsNullOrWhiteSpace(txtPreventiveAction.Text) ? (object)DBNull.Value : txtPreventiveAction.Text.Trim());
        cmd.Parameters.AddWithValue("@AdditionalComments", string.IsNullOrWhiteSpace(txtAdditionalComments.Text) ? (object)DBNull.Value : txtAdditionalComments.Text.Trim());
        
        // Equipment fields - Parse EatonID|Name format and store EatonID in name columns
        string ateValue = ddlAffectedATE.SelectedValue;
        if (!string.IsNullOrWhiteSpace(ateValue) && ateValue.Contains("|"))
        {
            string[] parts = ateValue.Split('|');
            cmd.Parameters.AddWithValue("@AffectedATE", parts[0]); // Store EatonID
        }
        else
        {
            cmd.Parameters.AddWithValue("@AffectedATE", string.IsNullOrWhiteSpace(ateValue) ? (object)DBNull.Value : ateValue);
        }
        
        string equipmentValue = ddlAffectedEquipment.SelectedValue;
        if (!string.IsNullOrWhiteSpace(equipmentValue) && equipmentValue.Contains("|"))
        {
            string[] parts = equipmentValue.Split('|');
            cmd.Parameters.AddWithValue("@AffectedEquipment", parts[0]); // Store EatonID
        }
        else
        {
            cmd.Parameters.AddWithValue("@AffectedEquipment", string.IsNullOrWhiteSpace(equipmentValue) ? (object)DBNull.Value : equipmentValue);
        }
        
        string fixtureValue = ddlAffectedFixture.SelectedValue;
        if (!string.IsNullOrWhiteSpace(fixtureValue) && fixtureValue.Contains("|"))
        {
            string[] parts = fixtureValue.Split('|');
            cmd.Parameters.AddWithValue("@AffectedFixture", parts[0]); // Store EatonID
        }
        else
        {
            cmd.Parameters.AddWithValue("@AffectedFixture", string.IsNullOrWhiteSpace(fixtureValue) ? (object)DBNull.Value : fixtureValue);
        }
        
        string harnessValue = ddlAffectedHarness.SelectedValue;
        if (!string.IsNullOrWhiteSpace(harnessValue) && harnessValue.Contains("|"))
        {
            string[] parts = harnessValue.Split('|');
            cmd.Parameters.AddWithValue("@AffectedHarness", parts[0]); // Store EatonID
        }
        else
        {
            cmd.Parameters.AddWithValue("@AffectedHarness", string.IsNullOrWhiteSpace(harnessValue) ? (object)DBNull.Value : harnessValue);
        }
        
        // Metrics
        cmd.Parameters.AddWithValue("@IsRepeat", chkIsRepeat.Checked);
        
        decimal downtimeHours;
        if (!string.IsNullOrWhiteSpace(txtDowntimeHours.Text) && decimal.TryParse(txtDowntimeHours.Text, out downtimeHours))
            cmd.Parameters.AddWithValue("@DowntimeHours", downtimeHours);
        else
            cmd.Parameters.AddWithValue("@DowntimeHours", DBNull.Value);
        
        cmd.Parameters.AddWithValue("@ImpactLevel", string.IsNullOrWhiteSpace(ddlImpactLevel.SelectedValue) ? (object)DBNull.Value : ddlImpactLevel.SelectedValue);
            cmd.Parameters.AddWithValue("@TroubleshootingID", string.IsNullOrWhiteSpace(txtTroubleshootingID.Text) ? (object)DBNull.Value : txtTroubleshootingID.Text);
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Response.Redirect("Troubleshooting.aspx");
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        // Check permissions for deleting
        if (!CanEdit)
        {
            ShowMessage("You do not have permission to delete troubleshooting logs.", "error");
            return;
        }
        
        if (!TroubleshootingID.HasValue) return;
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("DELETE FROM dbo.Troubleshooting_Log WHERE ID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", TroubleshootingID.Value);
                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();
                
                if (rowsAffected > 0)
                {
                    Response.Redirect("Troubleshooting.aspx?deleted=1");
                }
                else
                {
                    ShowMessage("Failed to delete troubleshooting log.", "error");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting troubleshooting log: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("btnDelete_Click error: " + ex.Message);
        }
    }

    private void ShowMessage(string message, string type = "success")
    {
        // Legacy toast and message removed. Use ShowBannerMessage instead.
        ShowBannerMessage(message, type);
    }
    
    // ========== FILE UPLOAD HELPER METHODS ==========
    
    private string HandleFileUploads(int logId, string location)
    {
        System.Diagnostics.Debug.WriteLine("HandleFileUploads called for logId: " + logId + ", location: " + location);
        
        // Debug: Check if file upload control exists and has files
        if (fileUpload == null)
        {
            ShowMessage("File upload control is null!", "error");
            return GetExistingAttachments(logId);
        }
        
        // ShowMessage("File upload control found. HasFiles: " + fileUpload.HasFiles + ", PostedFiles count: " + (fileUpload.PostedFiles != null ? fileUpload.PostedFiles.Count.ToString() : "null"), "info");
        
        if (fileUpload.HasFiles)
        {
            System.Diagnostics.Debug.WriteLine("Files detected: " + fileUpload.PostedFiles.Count);
            
            try
            {
                // Use the provided location instead of querying database
                System.Diagnostics.Debug.WriteLine("Using provided location: " + location);
                
                if (string.IsNullOrEmpty(location))
                {
                    ShowMessage("Cannot upload files: Location not found for this troubleshooting log.", "error");
                    return GetExistingAttachments(logId);
                }

                // Get the troubleshooting folder path using LocalFileSystemService
                string uploadPath = LocalFileSystemService.GetTroubleshootingFolderPath(logId.ToString(), location);
                System.Diagnostics.Debug.WriteLine("Initial uploadPath: " + uploadPath);
                // ShowMessage("Upload path: " + uploadPath, "info");
                
                // If folder doesn't exist, create it
                if (string.IsNullOrEmpty(uploadPath))
                {
                    System.Diagnostics.Debug.WriteLine("Folder doesn't exist, creating...");
                    bool folderCreated = LocalFileSystemService.CreateTroubleshootingFolder(logId.ToString(), location);
                    System.Diagnostics.Debug.WriteLine("Folder creation result: " + folderCreated);
                    
                    if (!folderCreated)
                    {
                        string error = LocalFileSystemService.GetLastError();
                        System.Diagnostics.Debug.WriteLine("Folder creation error: " + error);
                        ShowMessage("Cannot upload files: Failed to create troubleshooting folder. " + error, "error");
                        return GetExistingAttachments(logId);
                    }
                    // Try to get the path again after creation
                    uploadPath = LocalFileSystemService.GetTroubleshootingFolderPath(logId.ToString(), location);
                    System.Diagnostics.Debug.WriteLine("UploadPath after creation: " + uploadPath);
                    // ShowMessage("Upload path after creation: " + uploadPath, "info");
                    
                    if (string.IsNullOrEmpty(uploadPath))
                    {
                        ShowMessage("Cannot upload files: Troubleshooting folder not found after creation.", "error");
                        return GetExistingAttachments(logId);
                    }
                }

                List<string> uploadedFiles = new List<string>();
                // Get existing attachments if any (only for existing records)
                string existingAttachments = GetExistingAttachments(logId);
                System.Diagnostics.Debug.WriteLine("Existing attachments: " + existingAttachments);
                
                if (!string.IsNullOrEmpty(existingAttachments))
                {
                    uploadedFiles.AddRange(existingAttachments.Split(',').Select(f => f.Trim()).Where(f => !string.IsNullOrEmpty(f)));
                }
                
                // Allowed extensions
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".pdf", ".docx", ".xlsx", ".zip", ".txt", ".doc", ".xls", ".csv" };
                int maxFileSize = 10 * 1024 * 1024; // 10MB
                int filesUploaded = 0;
                
                foreach (var file in fileUpload.PostedFiles)
                {
                    System.Diagnostics.Debug.WriteLine("Processing file: " + file.FileName);
                    
                    string extension = Path.GetExtension(file.FileName).ToLower();
                    // Validate extension
                    if (!allowedExtensions.Contains(extension))
                    {
                        ShowMessage(string.Format("File '{0}' has an invalid extension. Allowed: {1}", file.FileName, string.Join(", ", allowedExtensions)), "error");
                        continue;
                    }
                    // Validate size
                    if (file.ContentLength > maxFileSize)
                    {
                        ShowMessage(string.Format("File '{0}' is too large. Maximum size is 10MB.", file.FileName), "error");
                        continue;
                    }
                    // Generate unique filename
                    string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                    string safeFileName = Path.GetFileNameWithoutExtension(file.FileName).Replace(" ", "_");
                    string fileName = string.Format("{0}_{1}{2}", timestamp, safeFileName, extension);
                    string filePath = Path.Combine(uploadPath, fileName);
                    
                    System.Diagnostics.Debug.WriteLine("Saving file to: " + filePath);
                    
                    try
                    {
                        // Save file
                        file.SaveAs(filePath);
                        System.Diagnostics.Debug.WriteLine("File saved successfully");
                        filesUploaded++;
                        
                        // Store relative path from Storage folder
                        string relativePath = string.Format("Storage/Troubleshooting/{0}_{1}/{2}", logId, LocalFileSystemService.SanitizeFolderName(location), fileName);
                        System.Diagnostics.Debug.WriteLine("Relative path: " + relativePath);
                        
                        uploadedFiles.Add(relativePath);
                    }
                    catch (Exception saveEx)
                    {
                        System.Diagnostics.Debug.WriteLine("Error saving file: " + saveEx.Message);
                        ShowMessage(string.Format("Error saving file '{0}': {1}", file.FileName, saveEx.Message), "error");
                        continue;
                    }
                }
                
                if (filesUploaded > 0)
                {
                    ShowMessage(string.Format("Successfully uploaded {0} file(s).", filesUploaded), "success");
                }
                
                string result = string.Join(",", uploadedFiles);
                System.Diagnostics.Debug.WriteLine("Final result: " + result);
                return result;
            }
            catch (Exception ex)
            {
                ShowMessage("Error uploading files: " + ex.Message, "error");
                System.Diagnostics.Debug.WriteLine("HandleFileUploads error: " + ex.Message);
                return GetExistingAttachments(logId); // Return existing on error
            }
        }
        
        System.Diagnostics.Debug.WriteLine("No files to upload");
        return GetExistingAttachments(logId); // No new files, return existing
    }
    
    private string GetExistingAttachments(int logId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT AttachmentsPath FROM dbo.Troubleshooting_Log WHERE ID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", logId);
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : "";
            }
        }
        catch
        {
            return "";
        }
    }
    
    private string GetTroubleshootingLocation(int logId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT Location FROM dbo.Troubleshooting_Log WHERE ID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", logId);
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : "";
            }
        }
        catch
        {
            return "";
        }
    }
    
    private void DisplayAttachments(string attachmentsPath)
    {
        if (string.IsNullOrEmpty(attachmentsPath))
        {
            litAttachments.Text = "<p style='opacity:0.6; font-size:13px;'>No attachments</p>";
            return;
        }
        
        var files = attachmentsPath.Split(',').Select(f => f.Trim()).Where(f => !string.IsNullOrEmpty(f));
        var html = new System.Text.StringBuilder();
        html.Append("<div class='attachments-list'>");
        
        bool canEdit = CanEdit;
        
        foreach (var filePath in files)
        {
            string fileName = Path.GetFileName(filePath);
            string extension = Path.GetExtension(fileName).ToLower();
            string icon = GetFileIcon(extension);
            
            // Encode the file path for URL
            string encodedFilePath = HttpUtility.UrlEncode(filePath);
            
            html.Append("<div class='attachment-item-wrapper'>");
            
            // Build the correct URL path including the application path
            string appPath = ResolveUrl("~/");
            string fileUrl = appPath + filePath.Replace("\\", "/");
            
            html.AppendFormat(@"
                <a href='{0}' target='_blank' class='attachment-item'>
                    {1}
                    <span>{2}</span>
                </a>", 
                fileUrl, 
                icon, 
                fileName);
            
            // Add delete button if user has permission
            if (canEdit && TroubleshootingID.HasValue)
            {
                html.AppendFormat(@"
                    <a href='?id={0}&deleteAttachment={1}' class='delete-btn' onclick='return confirm(""Are you sure you want to delete this attachment?"");' title='Delete attachment'>
                        <svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' stroke-linecap='round'>
                            <line x1='18' y1='6' x2='6' y2='18'/>
                            <line x1='6' y1='6' x2='18' y2='18'/>
                        </svg>
                    </a>", 
                    TroubleshootingID.Value,
                    encodedFilePath);
            }
            
            html.Append("</div>");
        }
        
        html.Append("</div>");
        litAttachments.Text = html.ToString();
    }
    
    private void DeleteAttachment(string filePathToDelete, int logId)
    {
        if (!CanEdit)
        {
            ShowMessage("You don't have permission to delete attachments.", "error");
            return;
        }
        
        try
        {
            // Decode the file path
            filePathToDelete = HttpUtility.UrlDecode(filePathToDelete);
            
            // Get current attachments
            string currentAttachments = GetExistingAttachments(logId);
            if (string.IsNullOrEmpty(currentAttachments))
            {
                return;
            }
            
            // Remove the file from the list
            var filesList = currentAttachments.Split(',').Select(f => f.Trim()).Where(f => !string.IsNullOrEmpty(f)).ToList();
            filesList.Remove(filePathToDelete);
            
            // Delete physical file
            string physicalPath = Server.MapPath("~/" + filePathToDelete);
            if (File.Exists(physicalPath))
            {
                File.Delete(physicalPath);
            }
            
            // Update database
            string newAttachments = string.Join(",", filesList);
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("UPDATE dbo.Troubleshooting_Log SET AttachmentsPath = @AttachmentsPath WHERE ID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", logId);
                cmd.Parameters.AddWithValue("@AttachmentsPath", string.IsNullOrEmpty(newAttachments) ? (object)DBNull.Value : newAttachments);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            
            ShowMessage("Attachment deleted successfully.", "success");
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting attachment: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("DeleteAttachment error: " + ex.Message);
        }
    }
    
    private string GetFileIcon(string extension)
    {
        switch (extension)
        {
            case ".jpg":
            case ".jpeg":
            case ".png":
            case ".gif":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
            case ".pdf":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='16' y1='13' x2='8' y2='13'/><line x1='16' y1='17' x2='8' y2='17'/><polyline points='10 9 9 9 8 9'/></svg>";
            case ".zip":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4'/><polyline points='7 10 12 15 17 10'/><line x1='12' y1='15' x2='12' y2='3'/></svg>";
            default:
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z'/><polyline points='13 2 13 9 20 9'/></svg>";
        }
    }
}
