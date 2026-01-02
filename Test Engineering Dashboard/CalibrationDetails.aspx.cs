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

public partial class TED_CalibrationDetails : Page
{
    private int? CalibrationID
    {
        get
        {
            if (ViewState["CalibrationID"] != null)
                return (int)ViewState["CalibrationID"];
            
            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int id;
                if (int.TryParse(Request.QueryString["id"], out id))
                    return id;
            }
            return null;
        }
        set { ViewState["CalibrationID"] = value; }
    }

    private bool IsNewMode
    {
        get { return Request.QueryString["mode"] == "new" || CalibrationID == null; }
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
                System.Diagnostics.Debug.WriteLine("PMDetails - User Category: " + userCategory);
                return userCategory == "Admin" || userCategory == "Test Engineering";
            }
            System.Diagnostics.Debug.WriteLine("PMDetails - No user category found in session");
            return false;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Handle action=viewFirst - redirect to first available calibration log
            if (Request.QueryString["action"] == "viewFirst")
            {
                RedirectToFirstCalibrationLog();
                return;
            }
            
            // Handle delete attachment request
            if (!string.IsNullOrEmpty(Request.QueryString["deleteAttachment"]) && CalibrationID.HasValue)
            {
                DeleteAttachment(Request.QueryString["deleteAttachment"], CalibrationID.Value);
                Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}", CalibrationID.Value));
                return;
            }
            
            LoadUsersDropdown();
            LoadCalibrationDropdown();
            
            if (IsNewMode)
            {
                SetupNewMode();
            }
            else if (CalibrationID.HasValue)
            {
                LoadCalibrationData(CalibrationID.Value);
                
                // Check for success message
                if (Request.QueryString["msg"] == "created")
                {
                    ShowMessage("calibration log created successfully!", "success");
                }
                else if (Request.QueryString["msg"] == "updated")
                {
                    ShowMessage("Changes saved successfully!", "success");
                }
            }
            else
            {
                ShowMessage("Invalid calibration log ID.", "error");
            }
            
            // Apply permissions AFTER loading data
            ApplyPermissions();
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
                ddlPerformedBy.Items.Clear();
                ddlPerformedBy.Items.Add(new ListItem(" ", ""));
                
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string fullName = reader["FullName"].ToString();
                        ddlPerformedBy.Items.Add(new ListItem(fullName, fullName));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadUsersDropdown error: " + ex.Message);
        }
    }
    
    private void LoadCalibrationDropdown()
    {
        try
        {
            // Always make dropdown visible and load data (needed for navigation from New mode)
            divCalibrationSelector.Visible = !IsNewMode;  // Keep hidden in new mode for cleaner UI
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 100 
                    CalibrationID, 
                    EquipmentType,
                    EquipmentEatonID,
                    EquipmentName,
                    CONVERT(VARCHAR(10), CalibrationDate, 101) AS CalibrationDateStr,
                    Status
                FROM dbo.Calibration_Log
                ORDER BY CalibrationID DESC", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    ddlCalibrationSelector.Items.Clear();
                    
                    while (reader.Read())
                    {
                        int id = Convert.ToInt32(reader["CalibrationID"]);
                        string eatonId = reader["EquipmentEatonID"] != DBNull.Value ? reader["EquipmentEatonID"].ToString() : "N/A";
                        string equipName = reader["EquipmentName"] != DBNull.Value ? reader["EquipmentName"].ToString() : "N/A";
                        string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";
                        
                        // Format: "CalibrationID | Equipment Eaton ID | Equipment Name (Status)"
                        string displayText = string.Format("#{0} | {1} | {2} ({3})", id, eatonId, equipName, status);
                        ddlCalibrationSelector.Items.Add(new ListItem(displayText, id.ToString()));
                    }
                }
            }
            
            // Set the selected value to current ID
            if (CalibrationID.HasValue && ddlCalibrationSelector.Items.FindByValue(CalibrationID.Value.ToString()) != null)
            {
                ddlCalibrationSelector.SelectedValue = CalibrationID.Value.ToString();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadCalibrationDropdown error: " + ex.Message);
            divCalibrationSelector.Visible = false;
        }
    }
    
    private void RedirectToFirstCalibrationLog()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Starting...");
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            if (string.IsNullOrEmpty(cs))
            {
                System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Connection string is null or empty!");
                Response.Redirect("Calibration.aspx");
                return;
            }
            
            System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Connection string OK, opening connection...");
            
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Connection opened successfully");
                
                using (var cmd = new SqlCommand("SELECT TOP 1 CalibrationID FROM dbo.Calibration_Log ORDER BY CalibrationID DESC", conn))
                {
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Executing query...");
                    var result = cmd.ExecuteScalar();
                    
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Query executed, result = " + (result == null ? "NULL" : result.ToString()));
                    
                    if (result != null)
                    {
                        int firstCalibrationID = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: Found Calibration Log ID " + firstCalibrationID + ", redirecting...");
                        Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}", firstCalibrationID), false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        // No calibration logs exist, redirect to new mode
                        System.Diagnostics.Debug.WriteLine("RedirectToFirstCalibrationLog: No calibration logs found, redirecting to new mode");
                        Response.Redirect("CalibrationDetails.aspx?mode=new", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("=== RedirectToFirstCalibrationLog ERROR ===");
            System.Diagnostics.Debug.WriteLine("Error Type: " + ex.GetType().Name);
            System.Diagnostics.Debug.WriteLine("Error Message: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine("Inner Exception: " + ex.InnerException.Message);
            }
            System.Diagnostics.Debug.WriteLine("=== END ERROR ===");
            
            // Redirect to dashboard with error flag
            Response.Redirect("Calibration.aspx?error=pmload", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
    
    protected void ddlCalibrationSelector_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlCalibrationSelector.SelectedValue))
        {
            Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}", ddlCalibrationSelector.SelectedValue));
        }
    }
    
    protected void ddlEquipmentID_SelectedIndexChanged(object sender, EventArgs e)
    {
        System.Diagnostics.Debug.WriteLine("========================================");
        System.Diagnostics.Debug.WriteLine("ddlEquipmentID_SelectedIndexChanged event fired!");
        System.Diagnostics.Debug.WriteLine(string.Format("Selected Value: {0}", ddlEquipmentID.SelectedValue));
        System.Diagnostics.Debug.WriteLine("========================================");
        LoadEquipmentDetails();
    }
    
    protected void ddlMethod_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Always keep all divs visible, only enable/disable inner controls
        divPerformedBy.Visible = true;
        divVendorName.Visible = true;
        divSentOutDate.Visible = true;
        divReceivedDate.Visible = true;
        bool isExternal = ddlMethod.SelectedValue == "External";
        ddlPerformedBy.Enabled = !isExternal;
        txtVendorName.Enabled = isExternal;
        txtSentOutDate.Enabled = isExternal;
        txtReceivedDate.Enabled = isExternal;
    }
    
    private void LoadEquipmentDropdown()
    {
        try
        {
            ddlEquipmentID.Items.Clear();
            ddlEquipmentID.Items.Add(new ListItem(" ", ""));
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            // Use the view to get all equipment requiring PM
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    EquipmentType,
                    EquipmentID,
                    EatonID,
                    EquipmentName,
                    Location
                FROM dbo.vw_Equipment_RequireCalibration
                ORDER BY EquipmentType, EatonID, EquipmentName", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string equipType = reader["EquipmentType"].ToString();
                        string equipId = reader["EquipmentID"].ToString();
                        string eatonId = reader["EatonID"] != DBNull.Value ? reader["EatonID"].ToString() : "";
                        string name = reader["EquipmentName"].ToString();
                        string location = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "";
                        
                        // Create a composite value: EquipmentType|EquipmentID
                        string value = string.Format("{0}|{1}", equipType, equipId);
                        
                        // Format display: Type - EatonID | Name (Location)
                        string displayText = string.Format("{0} - {1} | {2}{3}", 
                            equipType,
                            string.IsNullOrEmpty(eatonId) ? equipId : eatonId,
                            name,
                            string.IsNullOrEmpty(location) ? "" : " (" + location + ")");
                        
                        ddlEquipmentID.Items.Add(new ListItem(displayText, value));
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDropdown error: " + ex.Message);
        }
    }
    
    private void LoadEquipmentDetails()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails called");
            
            if (string.IsNullOrEmpty(ddlEquipmentID.SelectedValue))
            {
                System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails: No equipment selected, clearing fields");
                ClearEquipmentDetails();
                return;
            }
            
            // Parse the composite value
            string[] parts = ddlEquipmentID.SelectedValue.Split('|');
            System.Diagnostics.Debug.WriteLine(string.Format("LoadEquipmentDetails: Selected value = {0}, Parts count = {1}", ddlEquipmentID.SelectedValue, parts.Length));
            
            if (parts.Length != 2)
            {
                System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails: Invalid composite value format");
                return;
            }
            
            string equipmentType = parts[0];
            int equipmentId = int.Parse(parts[1]);
            System.Diagnostics.Debug.WriteLine(string.Format("LoadEquipmentDetails: Type = {0}, ID = {1}", equipmentType, equipmentId));
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            // Load equipment details from the view
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    EquipmentType,
                    CalibrationFrequency,
                    LastCalibration,
                    LastCalibratedBy,
                    NextCalibration,
                    Location,
                    CalibrationEstimatedTime
                FROM dbo.vw_Equipment_RequireCalibration
                WHERE EquipmentType = @EquipmentType AND EquipmentID = @EquipmentID", conn))
            {
                cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails: Equipment record found, populating fields");
                        
                        // Auto-populate equipment fields
                        txtEquipmentType.Text = reader["EquipmentType"].ToString();
                        txtCalibrationFrequency.Text = reader["CalibrationFrequency"] != DBNull.Value ? reader["CalibrationFrequency"].ToString() : "N/A";
                        
                        if (reader["LastCalibration"] != DBNull.Value)
                        {
                            DateTime lastCal = Convert.ToDateTime(reader["LastCalibration"]);
                            txtLastCalibration.Text = lastCal.ToString("MM/dd/yyyy");
                        }
                        else
                        {
                            txtLastCalibration.Text = "Never";
                        }
                        
                        txtLastCalibratedBy.Text = reader["LastCalibratedBy"] != DBNull.Value ? reader["LastCalibratedBy"].ToString() : "N/A";
                        
                        if (reader["NextCalibration"] != DBNull.Value)
                        {
                            DateTime nextCal = Convert.ToDateTime(reader["NextCalibration"]);
                            txtNextCalibration.Text = nextCal.ToString("MM/dd/yyyy");
                            
                            // Auto-populate Next Calibration Date in new mode
                            if (IsNewMode && string.IsNullOrEmpty(txtNextCalibrationDate.Text))
                            {
                                txtNextCalibrationDate.Text = nextCal.ToString("yyyy-MM-dd");
                            }
                        }
                        else
                        {
                            txtNextCalibration.Text = "Not Set";
                        }
                        
                        txtLocation.Text = reader["Location"] != DBNull.Value ? reader["Location"].ToString() : "N/A";
                        txtCalibrationEstimatedTime.Text = reader["CalibrationEstimatedTime"] != DBNull.Value ? reader["CalibrationEstimatedTime"].ToString() : "";
                        
                        System.Diagnostics.Debug.WriteLine(string.Format("LoadEquipmentDetails: Populated - Type={0}, Freq={1}, LastCal={2}", txtEquipmentType.Text, txtCalibrationFrequency.Text, txtLastCalibration.Text));
                    }
                    else
                    {
                        System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails: No equipment record found in database");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails error: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails stack trace: " + ex.StackTrace);
        }
    }    private void ClearEquipmentDetails()
    {
        txtEquipmentType.Text = "";
        txtCalibrationFrequency.Text = "";
        txtLastCalibration.Text = "";
        txtLastCalibratedBy.Text = "";
        txtNextCalibration.Text = "";
        txtLocation.Text = "";
        txtCalibrationEstimatedTime.Text = "";
    }
    
    private void SetupNewMode()
    {
        litPageTitle.Text = "New Calibration Log";
        litPageSubtitle.Text = "Create a new equipment calibration log entry";
        
        // Load equipment dropdown
        LoadEquipmentDropdown();
        
        // Pre-select "External" method for new records
        ddlMethod.SelectedValue = "External";
        
        // Make External method fields visible since External is pre-selected
        divPerformedBy.Visible = true;
        divVendorName.Visible = true;
        divSentOutDate.Visible = true;
        divReceivedDate.Visible = true;
        ddlPerformedBy.Enabled = false; // Disabled for External
        txtVendorName.Enabled = true;   // Enabled for External
        txtSentOutDate.Enabled = true;  // Enabled for External
        txtReceivedDate.Enabled = true; // Enabled for External
        
        txtID.Text = "(Auto-generated)";
        txtCompletedDate.Text = "";
        ddlStatus.SelectedIndex = 0;
        litSaveButtonText.Text = "Create Log";
        
        // Do not pre-fill technician name; leave blank by default
        
        btnDelete.Visible = false;
        // Button text is already set in ASPX: "Save Changes" by default
        // In new mode, we could change it, but let's keep it consistent
        
        // Show no attachments message for new records
        DisplayAttachments("");
    }    private void ApplyPermissions()
    {
        bool canEdit = CanEdit;
        
        // Disable all form controls if user doesn't have edit permission and not in new mode
        if (!canEdit && !IsNewMode)
        {
            // Disable all input controls
            ddlEquipmentID.Enabled = false;
            ddlMethod.Enabled = false;
            txtStartDate.Enabled = false;
            txtSentOutDate.Enabled = false;
            txtReceivedDate.Enabled = false;
            txtCompletedDate.Enabled = false;
            txtNextCalibrationDate.Enabled = false;
            ddlPerformedBy.Enabled = false;
            txtVendorName.Enabled = false;
            txtCost.Enabled = false;
            txtCalibrationCertificate.Enabled = false;
            txtCalibrationStandard.Enabled = false;
            ddlResultCode.Enabled = false;
            ddlStatus.Enabled = false;
            txtCalibrationResults.Enabled = false;
            txtComments.Enabled = false;
            fileUpload.Enabled = false;
            
            // Hide action buttons
            btnSave.Visible = false;
            btnDelete.Visible = false;
        }
        else if (canEdit && !IsNewMode)
        {
            // Explicitly enable controls for users with edit permission, but respect method-based logic
            ddlEquipmentID.Enabled = false; // Equipment field is always disabled in details mode
            ddlMethod.Enabled = true;
            txtStartDate.Enabled = true;
            txtSentOutDate.Enabled = true;
            txtReceivedDate.Enabled = true;
            txtCompletedDate.Enabled = true;
            txtNextCalibrationDate.Enabled = true;

            // Apply method-based field enabling/disabling
            bool isExternal = ddlMethod.SelectedValue == "External";
            ddlPerformedBy.Enabled = !isExternal;
            txtVendorName.Enabled = isExternal;
            txtSentOutDate.Enabled = isExternal;
            txtReceivedDate.Enabled = isExternal;

            txtCost.Enabled = true;
            txtCalibrationCertificate.Enabled = true;
            txtCalibrationStandard.Enabled = true;
            ddlResultCode.Enabled = true;
            ddlStatus.Enabled = true;
            txtCalibrationResults.Enabled = true;
            txtComments.Enabled = true;
            fileUpload.Enabled = true;

            // Show action buttons
            btnSave.Visible = true;
            btnDelete.Visible = true;
        }
        // For new mode (IsNewMode == true), controls are already enabled by default
    }

    private void LoadCalibrationData(int id)
    {
        try
        {
            litSaveButtonText.Text = "Save Changes";
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    CalibrationID,
                    CalibrationLogID,
                    EquipmentType,
                    EquipmentID,
                    CalibrationDate,
                    NextDueDate AS NextCalibrationDate,
                    CalibrationBy,
                    CalibrationCertificate,
                    CalibrationStandard,
                    CalibrationResults,
                    Status,
                    Comments,
                    Cost,
                    CreatedDate,
                    CreatedBy,
                    PrevDueDate,
                    StartDate,
                    SentOutDate,
                    ReceivedDate,
                    CompletedDate,
                    ResultCode,
                    VendorName,
                    Method,
                    AttachmentsPath
                FROM dbo.Calibration_Log
                WHERE CalibrationID = @CalibrationID", conn))
            {
                cmd.Parameters.AddWithValue("@CalibrationID", id);
                conn.Open();
                
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Display CalibrationLogID instead of regular ID
                        txtID.Text = reader["CalibrationLogID"] != DBNull.Value ? reader["CalibrationLogID"].ToString() : id.ToString();
                        
                        // Load equipment dropdown first
                        LoadEquipmentDropdown();
                        
                        // Equipment Type and ID
                        if (reader["EquipmentType"] != DBNull.Value && reader["EquipmentID"] != DBNull.Value)
                        {
                            string equipType = reader["EquipmentType"].ToString();
                            string equipId = reader["EquipmentID"].ToString();
                            string compositeValue = string.Format("{0}|{1}", equipType, equipId);
                            
                            if (ddlEquipmentID.Items.FindByValue(compositeValue) != null)
                            {
                                ddlEquipmentID.SelectedValue = compositeValue;
                                LoadEquipmentDetails(); // This will populate txtEquipmentType and other fields
                            }
                        }
                        
                        // Disable equipment field in details mode
                        ddlEquipmentID.Enabled = false;
                        
                        // Dates
                        if (reader["StartDate"] != DBNull.Value)
                        {
                            DateTime startDate = Convert.ToDateTime(reader["StartDate"]);
                            txtStartDate.Text = startDate.ToString("yyyy-MM-dd");
                        }
                        
                        if (reader["SentOutDate"] != DBNull.Value)
                        {
                            DateTime sentOutDate = Convert.ToDateTime(reader["SentOutDate"]);
                            txtSentOutDate.Text = sentOutDate.ToString("yyyy-MM-dd");
                        }
                        
                        if (reader["ReceivedDate"] != DBNull.Value)
                        {
                            DateTime receivedDate = Convert.ToDateTime(reader["ReceivedDate"]);
                            txtReceivedDate.Text = receivedDate.ToString("yyyy-MM-dd");
                        }
                        
                        if (reader["CompletedDate"] != DBNull.Value)
                        {
                            DateTime completedDate = Convert.ToDateTime(reader["CompletedDate"]);
                            txtCompletedDate.Text = completedDate.ToString("yyyy-MM-dd");
                        }
                        
                        if (reader["NextCalibrationDate"] != DBNull.Value)
                        {
                            DateTime nextCalibrationDate = Convert.ToDateTime(reader["NextCalibrationDate"]);
                            txtNextCalibrationDate.Text = nextCalibrationDate.ToString("yyyy-MM-dd");
                        }
                        
                        // Method and vendor fields
                        if (reader["Method"] != DBNull.Value)
                        {
                            ddlMethod.SelectedValue = reader["Method"].ToString();
                            // Always keep all divs visible, only enable/disable inner controls
                            divPerformedBy.Visible = true;
                            divVendorName.Visible = true;
                            divSentOutDate.Visible = true;
                            divReceivedDate.Visible = true;
                            bool isExternal = reader["Method"].ToString() == "External";
                            ddlPerformedBy.Enabled = !isExternal;
                            txtVendorName.Enabled = isExternal;
                            txtSentOutDate.Enabled = isExternal;
                            txtReceivedDate.Enabled = isExternal;
                        }
                        
                        if (reader["VendorName"] != DBNull.Value)
                            txtVendorName.Text = reader["VendorName"].ToString();
                        
                        // Cost
                        if (reader["Cost"] != DBNull.Value)
                            txtCost.Text = reader["Cost"].ToString();
                        
                        // Certificate and Standard
                        if (reader["CalibrationCertificate"] != DBNull.Value)
                            txtCalibrationCertificate.Text = reader["CalibrationCertificate"].ToString();
                        
                        if (reader["CalibrationStandard"] != DBNull.Value)
                            txtCalibrationStandard.Text = reader["CalibrationStandard"].ToString();
                        
                        // Result Code and Status
                        if (reader["ResultCode"] != DBNull.Value)
                            ddlResultCode.SelectedValue = reader["ResultCode"].ToString();
                        
                        if (reader["Status"] != DBNull.Value)
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                        
                        // Text fields
                        txtCalibrationResults.Text = reader["CalibrationResults"] != DBNull.Value ? reader["CalibrationResults"].ToString() : "";
                        txtComments.Text = reader["Comments"] != DBNull.Value ? reader["Comments"].ToString() : "";
                        
                        // Calibrated By
                        if (reader["CalibrationBy"] != DBNull.Value)
                        {
                            string calibratedBy = reader["CalibrationBy"].ToString();
                            if (ddlPerformedBy.Items.FindByText(calibratedBy) != null)
                                ddlPerformedBy.SelectedValue = ddlPerformedBy.Items.FindByText(calibratedBy).Value;
                        }
                                                // Created Date
                        if (reader["CreatedDate"] != DBNull.Value)
                        {
                            DateTime createdDate = Convert.ToDateTime(reader["CreatedDate"]);
                            txtCreatedDate.Text = createdDate.ToString("yyyy-MM-dd HH:mm:ss");
                        }
                        
                        // Display attachments
                        string attachmentsPath = reader["AttachmentsPath"] != DBNull.Value ? reader["AttachmentsPath"].ToString() : "";
                        DisplayAttachments(attachmentsPath);
                        
                        // Set page title
                        string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";
                        litPageTitle.Text = string.Format("Calibration Log #{0}", id);
                        litPageSubtitle.Text = string.Format("Equipment: {0} | Status: {1}", 
                            reader["EquipmentType"] != DBNull.Value ? reader["EquipmentType"].ToString() : "N/A", 
                            status);
                        
                        // Show delete button for existing records
                        btnDelete.Visible = true;
                    }
                    else
                    {
                        ShowMessage("calibration log not found.", "error");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading calibration data: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("LoadCalibrationData error: " + ex.Message);
        }
    }

    // Helper method to recursively find a control by ID
    private Control FindControlRecursive(Control root, string id)
    {
        if (root.ID == id)
            return root;

        foreach (Control child in root.Controls)
        {
            Control found = FindControlRecursive(child, id);
            if (found != null)
                return found;
        }

        return null;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        // Check permissions for editing (allow new records or edit permission)
        if (!IsNewMode && !CanEdit)
        {
            ShowBannerMessage("You do not have permission to edit calibration logs.", "error");
            return;
        }
        
        try
        {
            // List of mandatory fields and their labels
            var mandatoryFields = new List<KeyValuePair<string, string>>();
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlEquipmentID", "Equipment / Asset"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlMethod", "Method"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtStartDate", "Start Date"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtCompletedDate", "Completed Date"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtNextCalibrationDate", "Next Calibration"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlResultCode", "Result Code"));
            mandatoryFields.Add(new KeyValuePair<string, string>("ddlStatus", "Status"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtCost", "Cost"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtCalibrationCertificate", "Certificate #"));
            mandatoryFields.Add(new KeyValuePair<string, string>("txtCalibrationResults", "Calibration Results"));
            
            // Add method-specific mandatory fields
            if (ddlMethod.SelectedValue == "External")
            {
                mandatoryFields.Add(new KeyValuePair<string, string>("txtVendorName", "Vendor Name"));
                mandatoryFields.Add(new KeyValuePair<string, string>("txtSentOutDate", "Sent Out Date"));
                mandatoryFields.Add(new KeyValuePair<string, string>("txtReceivedDate", "Received Date"));
            }
            else if (ddlMethod.SelectedValue == "Internal")
            {
                mandatoryFields.Add(new KeyValuePair<string, string>("ddlPerformedBy", "Calibrated By"));
            }

            var missingFields = new List<string>();

            // Check each field
            foreach (KeyValuePair<string, string> field in mandatoryFields)
            {
                var control = FindControlRecursive(Page, field.Key);
                DropDownList ddl = control as DropDownList;
                TextBox txt = control as TextBox;
                if (ddl != null)
                {
                    if (string.IsNullOrWhiteSpace(ddl.SelectedValue))
                        missingFields.Add(field.Value);
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
                // Parse equipment selection to get type and ID
                if (string.IsNullOrEmpty(ddlEquipmentID.SelectedValue))
                {
                    ShowBannerMessage("Please select equipment to calibrate.", "error");
                    return;
                }
                
                string[] equipmentParts = ddlEquipmentID.SelectedValue.Split('|');
                if (equipmentParts.Length != 2)
                {
                    ShowBannerMessage("Invalid equipment selection.", "error");
                    return;
                }
                
                string equipmentType = equipmentParts[0];
                int equipmentId = int.Parse(equipmentParts[1]);
                
                // Get CalibrationDate, EatonID, and EquipmentName from equipment
                DateTime? scheduledDate = null;
                string equipmentEatonID = null;
                string equipmentName = null;
                
                using (var connSched = new SqlConnection(cs))
                using (var cmdSched = new SqlCommand(@"
                    SELECT NextCalibration, EatonID, EquipmentName 
                    FROM dbo.vw_Equipment_RequireCalibration 
                    WHERE EquipmentType = @EquipmentType AND EquipmentID = @EquipmentID", connSched))
                {
                    cmdSched.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmdSched.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    connSched.Open();
                    using (var reader = cmdSched.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["NextCalibration"] != DBNull.Value)
                                scheduledDate = Convert.ToDateTime(reader["NextCalibration"]);
                            if (reader["EatonID"] != DBNull.Value)
                                equipmentEatonID = reader["EatonID"].ToString();
                            if (reader["EquipmentName"] != DBNull.Value)
                                equipmentName = reader["EquipmentName"].ToString();
                        }
                    }
                }
                
                // INSERT new calibration log
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.Calibration_Log (
                        EquipmentType, EquipmentID, EquipmentEatonID, EquipmentName,
                        PrevDueDate, StartDate, SentOutDate, ReceivedDate, CompletedDate,
                        CalibrationDate, NextDueDate, Method, VendorName,
                        CalibrationBy, CalibrationCertificate, CalibrationStandard, CalibrationResults,
                        ResultCode, Status, Cost, Comments, CreatedBy, AttachmentsPath
                    ) VALUES (
                        @EquipmentType, @EquipmentID, @EquipmentEatonID, @EquipmentName,
                        @PrevDueDate, @StartDate, @SentOutDate, @ReceivedDate, @CompletedDate,
                        @CalibrationDate, @NextDueDate, @Method, @VendorName,
                        @CalibrationBy, @CalibrationCertificate, @CalibrationStandard, @CalibrationResults,
                        @ResultCode, @Status, @Cost, @Comments, @CreatedBy, @AttachmentsPath
                    );
                    SELECT SCOPE_IDENTITY();", conn))
                {
                    cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    cmd.Parameters.AddWithValue("@EquipmentEatonID", string.IsNullOrEmpty(equipmentEatonID) ? (object)DBNull.Value : equipmentEatonID);
                    cmd.Parameters.AddWithValue("@EquipmentName", string.IsNullOrEmpty(equipmentName) ? (object)DBNull.Value : equipmentName);
                    AddPMParameters(cmd);
                    cmd.Parameters.AddWithValue("@CreatedBy", Session["TED:FullName"] != null ? Session["TED:FullName"].ToString() : "");
                    cmd.Parameters.AddWithValue("@AttachmentsPath", ""); // Will be updated after file uploads
                    
                    conn.Open();
                    var newId = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    // Generate CalibrationLogID in format "ID_EquipmentEatonID" and update the record
                    string calibrationLogID = string.Format("{0}_{1}", newId, string.IsNullOrEmpty(equipmentEatonID) ? equipmentId.ToString() : equipmentEatonID);
                    using (var updateCmd = new SqlCommand("UPDATE dbo.Calibration_Log SET CalibrationLogID = @CalibrationLogID WHERE CalibrationID = @CalibrationID", conn))
                    {
                        updateCmd.Parameters.AddWithValue("@CalibrationID", newId);
                        updateCmd.Parameters.AddWithValue("@CalibrationLogID", calibrationLogID);
                        updateCmd.ExecuteNonQuery();
                    }
                    
                    // Handle file uploads after getting the new ID
                    string attachmentPaths = HandleFileUploads(newId);
                    if (!string.IsNullOrEmpty(attachmentPaths))
                    {
                        // Update with attachment paths
                        using (var updateCmd = new SqlCommand("UPDATE dbo.Calibration_Log SET AttachmentsPath = @AttachmentsPath WHERE CalibrationID = @CalibrationID", conn))
                        {
                            updateCmd.Parameters.AddWithValue("@CalibrationID", newId);
                            updateCmd.Parameters.AddWithValue("@AttachmentsPath", attachmentPaths);
                            updateCmd.ExecuteNonQuery();
                        }
                    }
                    
                    // Update equipment table with LastCalibration, LastCalibratedBy, and NextCalibration
                    string calibratedByForEquipment = ddlMethod.SelectedValue == "External" 
                        ? txtVendorName.Text.Trim() 
                        : ddlPerformedBy.SelectedItem.Text;
                    
                    UpdateEquipmentCalibrationFields(conn, equipmentType, equipmentId, 
                        DateTime.Parse(txtCompletedDate.Text), 
                        calibratedByForEquipment,
                        string.IsNullOrEmpty(txtNextCalibrationDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextCalibrationDate.Text));
                    
                    // Create local file system folder for this calibration
                    try
                    {
                        if (!string.IsNullOrWhiteSpace(equipmentEatonID))
                        {
                            bool folderCreated = LocalFileSystemService.CreateCalibrationFolder(newId.ToString(), equipmentEatonID);
                            if (!folderCreated)
                            {
                                string error = LocalFileSystemService.GetLastError();
                                System.Diagnostics.Debug.WriteLine("Calibration folder creation failed: " + error);
                            }
                        }
                    }
                    catch (Exception folderEx)
                    {
                        System.Diagnostics.Debug.WriteLine("Calibration folder error: " + folderEx.Message);
                    }
                    
                    Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}&msg=created", newId));
                }
            }
            else
            {
                // Parse equipment selection to get type and ID for UPDATE
                if (string.IsNullOrEmpty(ddlEquipmentID.SelectedValue))
                {
                    ShowBannerMessage("Please select equipment to calibrate.", "error");
                    return;
                }
                
                string[] equipmentParts = ddlEquipmentID.SelectedValue.Split('|');
                if (equipmentParts.Length != 2)
                {
                    ShowBannerMessage("Invalid equipment selection.", "error");
                    return;
                }
                
                string equipmentType = equipmentParts[0];
                int equipmentId = int.Parse(equipmentParts[1]);
                
                // Get EquipmentEatonID and EquipmentName from equipment for UPDATE
                string equipmentEatonID = null;
                string equipmentName = null;
                
                using (var connEquip = new SqlConnection(cs))
                using (var cmdEquip = new SqlCommand(@"
                    SELECT EatonID, EquipmentName 
                    FROM dbo.vw_Equipment_RequireCalibration 
                    WHERE EquipmentType = @EquipmentType AND EquipmentID = @EquipmentID", connEquip))
                {
                    cmdEquip.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmdEquip.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    connEquip.Open();
                    using (var reader = cmdEquip.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["EatonID"] != DBNull.Value)
                                equipmentEatonID = reader["EatonID"].ToString();
                            if (reader["EquipmentName"] != DBNull.Value)
                                equipmentName = reader["EquipmentName"].ToString();
                        }
                    }
                }
                
                // UPDATE existing calibration log
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.Calibration_Log SET
                        EquipmentType = @EquipmentType,
                        EquipmentID = @EquipmentID,
                        EquipmentEatonID = @EquipmentEatonID,
                        EquipmentName = @EquipmentName,
                        PrevDueDate = @PrevDueDate,
                        StartDate = @StartDate,
                        SentOutDate = @SentOutDate,
                        ReceivedDate = @ReceivedDate,
                        CompletedDate = @CompletedDate,
                        CalibrationDate = @CalibrationDate,
                        NextDueDate = @NextDueDate,
                        Method = @Method,
                        VendorName = @VendorName,
                        CalibrationBy = @CalibrationBy,
                        CalibrationCertificate = @CalibrationCertificate,
                        CalibrationStandard = @CalibrationStandard,
                        CalibrationResults = @CalibrationResults,
                        ResultCode = @ResultCode,
                        Status = @Status,
                        Cost = @Cost,
                        Comments = @Comments,
                        AttachmentsPath = @AttachmentsPath
                    WHERE CalibrationID = @CalibrationID", conn))
                {
                    cmd.Parameters.AddWithValue("@CalibrationID", CalibrationID.Value);
                    cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    cmd.Parameters.AddWithValue("@EquipmentEatonID", string.IsNullOrEmpty(equipmentEatonID) ? (object)DBNull.Value : equipmentEatonID);
                    cmd.Parameters.AddWithValue("@EquipmentName", string.IsNullOrEmpty(equipmentName) ? (object)DBNull.Value : equipmentName);
                    AddPMParameters(cmd);
                    
                    // Get existing attachments and add new ones
                    string existingAttachments = GetExistingAttachments(CalibrationID.Value);
                    string newAttachments = HandleFileUploads(CalibrationID.Value);
                    
                    string combinedAttachments = string.IsNullOrEmpty(existingAttachments) 
                        ? newAttachments 
                        : (string.IsNullOrEmpty(newAttachments) 
                            ? existingAttachments 
                            : existingAttachments + "," + newAttachments);
                    
                    cmd.Parameters.AddWithValue("@AttachmentsPath", combinedAttachments ?? "");
                    
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    
                    // Update equipment table with LastCalibration, LastCalibratedBy, and NextCalibration
                    // Update equipment table with LastCalibration, LastCalibratedBy, and NextCalibration
                    string calibratedByForEquipment = ddlMethod.SelectedValue == "External" 
                        ? txtVendorName.Text.Trim() 
                        : ddlPerformedBy.SelectedItem.Text;
                    
                    UpdateEquipmentCalibrationFields(conn, equipmentType, equipmentId, 
                        DateTime.Parse(txtCompletedDate.Text), 
                        calibratedByForEquipment,
                        string.IsNullOrEmpty(txtNextCalibrationDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextCalibrationDate.Text));
                }
                
                Response.Redirect(string.Format("CalibrationDetails.aspx?id={0}&msg=updated", CalibrationID.Value));
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving calibration log: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("btnSave_Click error: " + ex.Message);
        }
    }
    
    private DateTime? TryParseCalibrationDate(string dateStr)
    {
        if (string.IsNullOrWhiteSpace(dateStr) || dateStr == "N/A" || dateStr == "Not Set" || dateStr == "Never")
            return null;
        
        DateTime result;
        // Try multiple date formats
        string[] formats = { "MM/dd/yyyy", "yyyy-MM-dd", "MM/dd/yyyy HH:mm", "yyyy-MM-ddTHH:mm" };
        if (DateTime.TryParseExact(dateStr, formats, System.Globalization.CultureInfo.InvariantCulture, 
            System.Globalization.DateTimeStyles.None, out result))
        {
            return result;
        }
        
        // Fallback to standard parse
        if (DateTime.TryParse(dateStr, out result))
            return result;
        
        return null;
    }
    
    private void AddPMParameters(SqlCommand cmd)
    {
        // Date fields - PrevDueDate comes from Basic Information's Next Calibration
        string prevDueDateValue = txtNextCalibration.Text; // Read from readonly field in Basic Information
        
        cmd.Parameters.AddWithValue("@PrevDueDate", TryParseCalibrationDate(prevDueDateValue) ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@StartDate", TryParseCalibrationDate(txtStartDate.Text) ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@SentOutDate", TryParseCalibrationDate(txtSentOutDate.Text) ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@ReceivedDate", TryParseCalibrationDate(txtReceivedDate.Text) ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@CompletedDate", TryParseCalibrationDate(txtCompletedDate.Text) ?? (object)DBNull.Value);
        // CalibrationDate = CompletedDate (same value)
        cmd.Parameters.AddWithValue("@CalibrationDate", TryParseCalibrationDate(txtCompletedDate.Text) ?? (object)DBNull.Value);
        cmd.Parameters.AddWithValue("@NextDueDate", TryParseCalibrationDate(txtNextCalibrationDate.Text) ?? (object)DBNull.Value);
        
        // Method and vendor
        cmd.Parameters.AddWithValue("@Method", ddlMethod.SelectedValue);
        cmd.Parameters.AddWithValue("@VendorName", string.IsNullOrEmpty(txtVendorName.Text) ? (object)DBNull.Value : txtVendorName.Text.Trim());
        
        // Calibration details
        // For External method: CalibrationBy = VendorName
        // For Internal method: CalibrationBy = selected technician
        string calibrationBy = "";
        if (ddlMethod.SelectedValue == "External")
        {
            calibrationBy = string.IsNullOrEmpty(txtVendorName.Text) ? "" : txtVendorName.Text.Trim();
        }
        else
        {
            calibrationBy = ddlPerformedBy.SelectedItem != null ? ddlPerformedBy.SelectedItem.Text : "";
        }
        cmd.Parameters.AddWithValue("@CalibrationBy", calibrationBy);
        cmd.Parameters.AddWithValue("@CalibrationCertificate", string.IsNullOrEmpty(txtCalibrationCertificate.Text) ? (object)DBNull.Value : txtCalibrationCertificate.Text.Trim());
        cmd.Parameters.AddWithValue("@CalibrationStandard", string.IsNullOrEmpty(txtCalibrationStandard.Text) ? (object)DBNull.Value : txtCalibrationStandard.Text.Trim());
        cmd.Parameters.AddWithValue("@CalibrationResults", string.IsNullOrEmpty(txtCalibrationResults.Text) ? (object)DBNull.Value : txtCalibrationResults.Text.Trim());
        cmd.Parameters.AddWithValue("@ResultCode", ddlResultCode.SelectedValue);
        cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
        
        // Cost
        decimal cost;
        cmd.Parameters.AddWithValue("@Cost", string.IsNullOrEmpty(txtCost.Text) || !decimal.TryParse(txtCost.Text, out cost) ? (object)DBNull.Value : cost);
        
        cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(txtComments.Text) ? (object)DBNull.Value : txtComments.Text.Trim());
    }
    
    private void UpdateEquipmentCalibrationFields(SqlConnection conn, string equipmentType, int equipmentId, DateTime lastCalibration, string lastCalibratedBy, DateTime? nextCalibration)
    {
        try
        {
            string tableName = "";
            string idColumn = "";
            string lastCalibratedByColumn = "";
            
            // Determine table name, ID column, and correct LastCalibratedBy column name based on equipment type
            switch (equipmentType)
            {
                case "ATE":
                    tableName = "ATE_Inventory";
                    idColumn = "ATEInventoryID";
                    lastCalibratedByColumn = "LastCalibratedBy";
                    break;
                case "Asset":
                    tableName = "Asset_Inventory";
                    idColumn = "AssetID";
                    lastCalibratedByColumn = "CalibratedBy";
                    break;
                case "Fixture":
                    tableName = "Fixture_Inventory";
                    idColumn = "FixtureID";
                    lastCalibratedByColumn = "CalibratedBy";
                    break;
                case "Harness":
                    tableName = "Harness_Inventory";
                    idColumn = "HarnessID";
                    lastCalibratedByColumn = "CalibratedBy";
                    break;
                default:
                    System.Diagnostics.Debug.WriteLine("UpdateEquipmentCalibrationFields: Unknown equipment type - " + equipmentType);
                    return;
            }
            
            // Build and execute the UPDATE statement
            string updateQuery = string.Format(@"
                UPDATE dbo.{0}
                SET LastCalibration = @LastCalibration,
                    {1} = @LastCalibratedBy,
                    NextCalibration = @NextCalibration
                WHERE {2} = @EquipmentID", 
                tableName, lastCalibratedByColumn, idColumn);
            
            using (var updateCmd = new SqlCommand(updateQuery, conn))
            {
                updateCmd.Parameters.AddWithValue("@LastCalibration", lastCalibration);
                updateCmd.Parameters.AddWithValue("@LastCalibratedBy", lastCalibratedBy);
                updateCmd.Parameters.AddWithValue("@NextCalibration", nextCalibration.HasValue ? (object)nextCalibration.Value : DBNull.Value);
                updateCmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                
                updateCmd.ExecuteNonQuery();
                System.Diagnostics.Debug.WriteLine(string.Format("Updated {0} ID {1} with LastCalibration={2}, {3}={4}, NextCalibration={5}", 
                    tableName, equipmentId, lastCalibration, lastCalibratedByColumn, lastCalibratedBy, nextCalibration.HasValue ? nextCalibration.Value.ToString() : "NULL"));
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("UpdateEquipmentCalibrationFields error: " + ex.Message);
            throw; // Re-throw to ensure transaction rollback if needed
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        // Check permissions for deleting
        if (!CanEdit)
        {
            ShowMessage("You do not have permission to delete calibration logs.", "error");
            return;
        }
        
        if (!CalibrationID.HasValue) return;
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("DELETE FROM dbo.Calibration_Log WHERE CalibrationID = @CalibrationID", conn))
            {
                cmd.Parameters.AddWithValue("@CalibrationID", CalibrationID.Value);
                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();
                
                if (rowsAffected > 0)
                {
                    Response.Redirect("Calibration.aspx?deleted=1");
                }
                else
                {
                    ShowMessage("Failed to delete calibration log.", "error");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting calibration log: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("btnDelete_Click error: " + ex.Message);
        }
    }

    private void ShowMessage(string message, string type = "success")
    {
        // Legacy toast and message removed. Use ShowBannerMessage instead.
        ShowBannerMessage(message, type);
    }
    
    // Modern top banner notification
    private void ShowBannerMessage(string message, string type = "info")
    {
        string safeMessage = message.Replace("'", "\'").Replace("\n", " ").Replace("\r", " ");
        string script = string.Format("window.showBannerMsg('{0}', '{1}');", safeMessage, type);
        // Try both ScriptManager and ClientScript for reliability
        if (ScriptManager.GetCurrent(Page) != null)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showBannerMsg", script, true);
        }
        Page.ClientScript.RegisterStartupScript(this.GetType(), "showBannerMsgFallback", "<script type='text/javascript'>" + script + "</script>");
    }

    private string HandleFileUploads(int logId)
    {
        if (!fileUpload.HasFiles)
            return string.Empty;
        
        try
        {
            // Get the calibration folder path - always use Storage folder
            string equipmentEatonID = GetEquipmentEatonIDForCalibration(logId);
            string uploadFolder = LocalFileSystemService.GetCalibrationFolderPath(logId.ToString(), equipmentEatonID ?? "Unknown");
            
            // If folder doesn't exist, try to create it
            if (string.IsNullOrEmpty(uploadFolder))
            {
                bool folderCreated = LocalFileSystemService.CreateCalibrationFolder(logId.ToString(), equipmentEatonID ?? "Unknown");
                if (folderCreated)
                {
                    uploadFolder = LocalFileSystemService.GetCalibrationFolderPath(logId.ToString(), equipmentEatonID ?? "Unknown");
                }
                else
                {
                    ShowMessage("Failed to create storage folder for attachments: " + LocalFileSystemService.GetLastError(), "error");
                    return string.Empty;
                }
            }
            
            var savedFiles = new List<string>();
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".gif", ".pdf", ".docx", ".xlsx", ".zip", ".txt", ".doc", ".xls" };
            const int maxFileSize = 10 * 1024 * 1024; // 10MB
            
            foreach (var uploadedFile in fileUpload.PostedFiles)
            {
                // Validate file extension
                string extension = Path.GetExtension(uploadedFile.FileName).ToLower();
                if (!allowedExtensions.Contains(extension))
                {
                    ShowMessage(string.Format("File {0} has an invalid extension. Skipping.", uploadedFile.FileName), "error");
                    continue;
                }
                
                // Validate file size
                if (uploadedFile.ContentLength > maxFileSize)
                {
                    ShowMessage(string.Format("File {0} exceeds maximum size of 10MB. Skipping.", uploadedFile.FileName), "error");
                    continue;
                }
                
                // Generate unique filename
                string timestamp = DateTime.Now.ToString("yyyyMMddHHmmss");
                string safeFileName = Path.GetFileNameWithoutExtension(uploadedFile.FileName).Replace(" ", "_");
                string fileName = string.Format("{0}_{1}{2}", timestamp, safeFileName, extension);
                string filePath = Path.Combine(uploadFolder, fileName);
                
                // Save file
                uploadedFile.SaveAs(filePath);
                
                // Store relative path from the Storage base path
                string baseStoragePath = Server.MapPath(LocalFileSystemService.GetBaseStoragePath());
                if (filePath.StartsWith(baseStoragePath))
                {
                    // File is in Storage folder, store relative path
                    string relativePath = filePath.Substring(baseStoragePath.Length).TrimStart('\\', '/');
                    savedFiles.Add(string.Format("Storage/{0}", relativePath.Replace('\\', '/')));
                }
                else
                {
                    // This should not happen with the new logic, but fallback just in case
                    ShowMessage("Warning: File was not saved to expected Storage location.", "error");
                    savedFiles.Add(string.Format("Storage/Calibration Logs/{0}_{1}/{2}", logId, LocalFileSystemService.SanitizeFolderName(equipmentEatonID ?? "Unknown"), fileName));
                }
            }
            
            return string.Join(",", savedFiles);
        }
        catch (Exception ex)
        {
            ShowMessage("Error uploading files: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("HandleFileUploads error: " + ex.Message);
            return string.Empty;
        }
    }
    
    private string GetExistingAttachments(int logId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT AttachmentsPath FROM dbo.Calibration_Log WHERE CalibrationID = @CalibrationID", conn))
            {
                cmd.Parameters.AddWithValue("@CalibrationID", logId);
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
            
            // Build the correct URL path including the application path
            string appPath = ResolveUrl("~/");
            string fileUrl;
            
            if (filePath.StartsWith("Storage/"))
            {
                // New storage path - convert to network path for display
                string physicalPath = Server.MapPath("~/" + filePath);
                fileUrl = LocalFileSystemService.ConvertToNetworkPath(physicalPath);
                if (string.IsNullOrEmpty(fileUrl) || fileUrl == physicalPath)
                {
                    // Fallback to direct URL if network path conversion fails
                    fileUrl = appPath + filePath.Replace("\\", "/");
                }
            }
            else
            {
                // Old uploads path
                fileUrl = appPath + filePath.Replace("\\", "/");
            }
            
            html.Append("<div class='attachment-item-wrapper'>");
            
            html.AppendFormat(@"
                <a href='{0}' target='_blank' class='attachment-item'>
                    {1}
                    <span>{2}</span>
                </a>", 
                fileUrl, 
                icon, 
                fileName);
            
            // Add delete button if user has permission
            if (canEdit && CalibrationID.HasValue)
            {
                html.AppendFormat(@"
                    <a href='?id={0}&deleteAttachment={1}' class='delete-btn' onclick='return confirm(""Are you sure you want to delete this attachment?"");' title='Delete attachment'>
                        <svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' stroke-linecap='round'>
                            <line x1='18' y1='6' x2='6' y2='18'/>
                            <line x1='6' y1='6' x2='18' y2='18'/>
                        </svg>
                    </a>", 
                    CalibrationID.Value,
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
            string decodedPath = HttpUtility.UrlDecode(filePathToDelete);
            
            // Get current attachments
            string currentAttachments = GetExistingAttachments(logId);
            if (string.IsNullOrEmpty(currentAttachments))
                return;
            
            // Remove the file from the list
            var fileList = currentAttachments.Split(',').Select(f => f.Trim()).ToList();
            fileList.Remove(decodedPath);
            string updatedAttachments = string.Join(",", fileList);
            
            // Delete physical file
            string physicalPath = Server.MapPath("~/" + decodedPath);
            if (File.Exists(physicalPath))
            {
                File.Delete(physicalPath);
            }
            
            // Update database
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("UPDATE dbo.Calibration_Log SET AttachmentsPath = @AttachmentsPath WHERE CalibrationID = @CalibrationID", conn))
            {
                cmd.Parameters.AddWithValue("@CalibrationID", logId);
                cmd.Parameters.AddWithValue("@AttachmentsPath", updatedAttachments);
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
        switch (extension.ToLower())
        {
            case ".jpg":
            case ".jpeg":
            case ".png":
            case ".gif":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><rect x='3' y='3' width='18' height='18' rx='2' ry='2'/><circle cx='8.5' cy='8.5' r='1.5'/><polyline points='21 15 16 10 5 21'/></svg>";
            case ".pdf":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='16' y1='13' x2='8' y2='13'/><line x1='16' y1='17' x2='8' y2='17'/><polyline points='10 9 9 9 8 9'/></svg>";
            case ".docx":
            case ".doc":
            case ".txt":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='16' y1='13' x2='8' y2='13'/><line x1='16' y1='17' x2='8' y2='17'/></svg>";
            case ".xlsx":
            case ".xls":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='8' y1='13' x2='16' y2='13'/><line x1='8' y1='17' x2='16' y2='17'/><line x1='12' y1='13' x2='12' y2='17'/></svg>";
            case ".zip":
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z'/><polyline points='14 2 14 8 20 8'/><line x1='12' y1='18' x2='12' y2='12'/><line x1='9' y1='15' x2='15' y2='15'/></svg>";
            default:
                return "<svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2'><path d='M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z'/><polyline points='13 2 13 9 20 9'/></svg>";
        }
    }
    
    private string GetEquipmentEatonIDForCalibration(int calibrationId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT EquipmentEatonID FROM dbo.Calibration_Log WHERE CalibrationID = @CalibrationID", conn))
            {
                cmd.Parameters.AddWithValue("@CalibrationID", calibrationId);
                conn.Open();
                var result = cmd.ExecuteScalar();
                return result != null && result != DBNull.Value ? result.ToString() : null;
            }
        }
        catch
        {
            return null;
        }
    }
}
