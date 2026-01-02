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

public partial class TED_PMDetails : Page
{
    private int? PMLogID
    {
        get
        {
            if (ViewState["PMLogID"] != null)
                return (int)ViewState["PMLogID"];
            
            if (!string.IsNullOrEmpty(Request.QueryString["id"]))
            {
                int id;
                if (int.TryParse(Request.QueryString["id"], out id))
                    return id;
            }
            return null;
        }
        set { ViewState["PMLogID"] = value; }
    }

    private bool IsNewMode
    {
        get { return Request.QueryString["mode"] == "new" || PMLogID == null; }
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
            // Handle action=viewFirst - redirect to first available PM log
            if (Request.QueryString["action"] == "viewFirst")
            {
                RedirectToFirstPMLog();
                return;
            }
            
            // Handle delete attachment request
            if (!string.IsNullOrEmpty(Request.QueryString["deleteAttachment"]) && PMLogID.HasValue)
            {
                DeleteAttachment(Request.QueryString["deleteAttachment"], PMLogID.Value);
                Response.Redirect(string.Format("PMDetails.aspx?id={0}", PMLogID.Value));
                return;
            }
            
            LoadUsersDropdown();
            LoadPMDropdown();
            
            if (IsNewMode)
            {
                SetupNewMode();
            }
            else if (PMLogID.HasValue)
            {
                LoadPMData(PMLogID.Value);
                
                // Check for success message
                if (Request.QueryString["msg"] == "created")
                {
                    ShowMessage("PM log created successfully!", "success");
                }
                else if (Request.QueryString["msg"] == "updated")
                {
                    ShowMessage("Changes saved successfully!", "success");
                }
            }
            else
            {
                ShowMessage("Invalid PM log ID.", "error");
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
                
                // Always add a blank option first
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
    
    private void LoadPMDropdown()
    {
        try
        {
            // Always make dropdown visible and load data (needed for navigation from New mode)
            divPMSelector.Visible = !IsNewMode;  // Keep hidden in new mode for cleaner UI
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT TOP 100 
                    PMLogID, 
                    EquipmentType,
                    EquipmentEatonID,
                    EquipmentName,
                    CONVERT(VARCHAR(10), PMDate, 101) AS PMDateStr,
                    Status
                FROM dbo.PM_Log
                ORDER BY PMLogID DESC", conn))
            {
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    ddlPMSelector.Items.Clear();
                    
                    while (reader.Read())
                    {
                        int id = Convert.ToInt32(reader["PMLogID"]);
                        string eatonId = reader["EquipmentEatonID"] != DBNull.Value ? reader["EquipmentEatonID"].ToString() : "N/A";
                        string equipName = reader["EquipmentName"] != DBNull.Value ? reader["EquipmentName"].ToString() : "N/A";
                        string status = reader["Status"] != DBNull.Value ? reader["Status"].ToString() : "";
                        
                        // Format: "PMLogID | Equipment Eaton ID | Equipment Name (Status)"
                        string displayText = string.Format("#{0} | {1} | {2} ({3})", id, eatonId, equipName, status);
                        ddlPMSelector.Items.Add(new ListItem(displayText, id.ToString()));
                    }
                }
            }
            
            // Set the selected value to current ID
            if (PMLogID.HasValue && ddlPMSelector.Items.FindByValue(PMLogID.Value.ToString()) != null)
            {
                ddlPMSelector.SelectedValue = PMLogID.Value.ToString();
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadPMDropdown error: " + ex.Message);
            divPMSelector.Visible = false;
        }
    }
    
    private void RedirectToFirstPMLog()
    {
        try
        {
            System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Starting...");
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            if (string.IsNullOrEmpty(cs))
            {
                System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Connection string is null or empty!");
                Response.Redirect("PreventiveMaintenance.aspx");
                return;
            }
            
            System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Connection string OK, opening connection...");
            
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Connection opened successfully");
                
                using (var cmd = new SqlCommand("SELECT TOP 1 PMLogID FROM dbo.PM_Log ORDER BY PMLogID DESC", conn))
                {
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Executing query...");
                    var result = cmd.ExecuteScalar();
                    
                    System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Query executed, result = " + (result == null ? "NULL" : result.ToString()));
                    
                    if (result != null)
                    {
                        int firstPMLogID = Convert.ToInt32(result);
                        System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: Found PM Log ID " + firstPMLogID + ", redirecting...");
                        Response.Redirect(string.Format("PMDetails.aspx?id={0}", firstPMLogID), false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                    else
                    {
                        // No PM logs exist, redirect to new mode
                        System.Diagnostics.Debug.WriteLine("RedirectToFirstPMLog: No PM logs found, redirecting to new mode");
                        Response.Redirect("PMDetails.aspx?mode=new", false);
                        Context.ApplicationInstance.CompleteRequest();
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("=== RedirectToFirstPMLog ERROR ===");
            System.Diagnostics.Debug.WriteLine("Error Type: " + ex.GetType().Name);
            System.Diagnostics.Debug.WriteLine("Error Message: " + ex.Message);
            System.Diagnostics.Debug.WriteLine("Stack Trace: " + ex.StackTrace);
            if (ex.InnerException != null)
            {
                System.Diagnostics.Debug.WriteLine("Inner Exception: " + ex.InnerException.Message);
            }
            System.Diagnostics.Debug.WriteLine("=== END ERROR ===");
            
            // Redirect to dashboard with error flag
            Response.Redirect("PreventiveMaintenance.aspx?error=pmload", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
    
    protected void ddlPMSelector_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ddlPMSelector.SelectedValue))
        {
            Response.Redirect(string.Format("PMDetails.aspx?id={0}", ddlPMSelector.SelectedValue));
        }
    }
    
    protected void ddlEquipmentID_SelectedIndexChanged(object sender, EventArgs e)
    {
        LoadEquipmentDetails();
    }
    
    private void LoadEquipmentDropdown()
    {
        try
        {
            ddlEquipmentID.Items.Clear();
            
            // Always add a blank option first
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
                FROM dbo.vw_Equipment_RequirePM
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
            if (string.IsNullOrEmpty(ddlEquipmentID.SelectedValue))
            {
                ClearEquipmentFields();
                return;
            }
            
            // Parse the composite value
            string[] parts = ddlEquipmentID.SelectedValue.Split('|');
            if (parts.Length != 2)
                return;
            
            string equipmentType = parts[0];
            int equipmentId = int.Parse(parts[1]);
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            // Load equipment details from the view
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    EquipmentType,
                    PMFrequency,
                    PMResponsible,
                    LastPM,
                    LastPMBy,
                    NextPM,
                    PMEstimatedTime
                FROM dbo.vw_Equipment_RequirePM
                WHERE EquipmentType = @EquipmentType AND EquipmentID = @EquipmentID", conn))
            {
                cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                
                conn.Open();
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Auto-populate equipment fields
                        txtEquipmentType.Text = reader["EquipmentType"].ToString();
                        txtPMFrequency.Text = reader["PMFrequency"] != DBNull.Value ? reader["PMFrequency"].ToString() : "";
                        txtPMResponsible.Text = reader["PMResponsible"] != DBNull.Value ? reader["PMResponsible"].ToString() : "";
                        
                        if (reader["LastPM"] != DBNull.Value)
                        {
                            DateTime lastPM = Convert.ToDateTime(reader["LastPM"]);
                            txtLastPMDate.Text = lastPM.ToString("MM/dd/yyyy HH:mm");
                        }
                        else
                        {
                            txtLastPMDate.Text = "N/A";
                        }
                        
                        txtLastPMBy.Text = reader["LastPMBy"] != DBNull.Value ? reader["LastPMBy"].ToString() : "N/A";
                        
                        if (reader["NextPM"] != DBNull.Value)
                        {
                            DateTime nextPM = Convert.ToDateTime(reader["NextPM"]);
                            txtNextPM.Text = nextPM.ToString("MM/dd/yyyy HH:mm");
                            
                            // Auto-populate Scheduled Date in new mode
                            if (IsNewMode)
                            {
                                txtScheduledDate.Text = nextPM.ToString("yyyy-MM-dd");
                            }
                        }
                        else
                        {
                            txtNextPM.Text = "N/A";
                            if (IsNewMode)
                            {
                                txtScheduledDate.Text = "";
                            }
                        }
                        
                        if (reader["PMEstimatedTime"] != DBNull.Value)
                        {
                            decimal estimatedTime = Convert.ToDecimal(reader["PMEstimatedTime"]);
                            txtPMEstimatedTime.Text = estimatedTime.ToString("0.00");
                        }
                        else
                        {
                            txtPMEstimatedTime.Text = "N/A";
                        }
                    }
                }
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("LoadEquipmentDetails error: " + ex.Message);
        }
    }
    
    private void ClearEquipmentFields()
    {
        txtEquipmentType.Text = "";
        txtPMFrequency.Text = "";
        txtPMResponsible.Text = "";
        txtLastPMDate.Text = "";
        txtLastPMBy.Text = "";
        txtNextPM.Text = "";
        txtPMEstimatedTime.Text = "";
    }
    
    private void SetupNewMode()
    {
        litPageTitle.Text = "New PM Log";
        litPageSubtitle.Text = "Create a new preventive maintenance log entry";
        
        // Load equipment dropdown
        LoadEquipmentDropdown();
        
        txtID.Text = "(Auto-generated)";
        txtPMDate.Text = ""; // Clear PM Date for new mode
        // ddlStatus remains blank for new mode
        
        // Performed By dropdown remains blank for new mode (no auto-selection)
        
        btnDelete.Visible = false;
        btnSave.Text = "<span aria-hidden='true' class='icon'><svg viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'><path d='M12 5v14'/><path d='M5 12h14'/></svg></span><span class='txt'>Create Log</span>";
        
        // Show no attachments message for new records
        DisplayAttachments("");
    }
    
    private void ApplyPermissions()
    {
        bool canEdit = CanEdit;
        
        // Disable all form controls if user doesn't have edit permission and not in new mode
        if (!canEdit && !IsNewMode)
        {
            // Disable all input controls
            ddlEquipmentID.Enabled = false;
            txtPMDate.Enabled = false;
            txtNextPMDate.Enabled = false;
            ddlPMType.Enabled = false;
            txtMaintenancePerformed.Enabled = false;
            ddlPerformedBy.Enabled = false;
            ddlStatus.Enabled = false;
            txtPartsReplaced.Enabled = false;
            txtCost.Enabled = false;
            txtComments.Enabled = false;
            txtActualStartTime.Enabled = false;
            txtActualEndTime.Enabled = false;
            txtDowntime.Enabled = false;
            fileUpload.Enabled = false;
            
            // Hide action buttons
            btnSave.Visible = false;
            btnDelete.Visible = false;
        }
        else if (canEdit && !IsNewMode)
        {
            // Explicitly enable controls for users with edit permission
            ddlEquipmentID.Enabled = false; // Equipment field is always disabled in details mode
            txtPMDate.Enabled = true;
            txtNextPMDate.Enabled = true;
            ddlPMType.Enabled = true;
            txtMaintenancePerformed.Enabled = true;
            ddlPerformedBy.Enabled = true;
            ddlStatus.Enabled = true;
            txtPartsReplaced.Enabled = true;
            txtCost.Enabled = true;
            txtComments.Enabled = true;
            txtActualStartTime.Enabled = true;
            txtActualEndTime.Enabled = true;
            txtDowntime.Enabled = true;
            fileUpload.Enabled = true;
            
            // Show action buttons
            btnSave.Visible = true;
            btnDelete.Visible = true;
        }
        // For new mode (IsNewMode == true), controls are already enabled by default
    }

    private void LoadPMData(int id)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"
                SELECT 
                    PMLogID,
                    EquipmentType,
                    EquipmentID,
                    PMDate,
                    NextPMDate,
                    PMType,
                    MaintenancePerformed,
                    PerformedBy,
                    PartsReplaced,
                    Cost,
                    Status,
                    Comments,
                    CreatedDate,
                    AttachmentsPath,
                    ScheduledDate,
                    ActualStartTime,
                    ActualEndTime,
                    Downtime,
                    PMID
                FROM dbo.PM_Log
                WHERE PMLogID = @PMLogID", conn))
            {
                cmd.Parameters.AddWithValue("@PMLogID", id);
                conn.Open();
                
                using (var reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        // Set PM ID from PMID column
                        txtID.Text = reader["PMID"] != DBNull.Value ? reader["PMID"].ToString() : id.ToString();
                        
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
                        
                        // Dates
                        if (reader["ScheduledDate"] != DBNull.Value)
                        {
                            DateTime scheduledDate = Convert.ToDateTime(reader["ScheduledDate"]);
                            txtScheduledDate.Text = scheduledDate.ToString("yyyy-MM-dd");
                        }
                        
                        if (reader["PMDate"] != DBNull.Value)
                        {
                            DateTime pmDate = Convert.ToDateTime(reader["PMDate"]);
                            txtPMDate.Text = pmDate.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        if (reader["NextPMDate"] != DBNull.Value)
                        {
                            DateTime nextPMDate = Convert.ToDateTime(reader["NextPMDate"]);
                            txtNextPMDate.Text = nextPMDate.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        if (reader["ActualStartTime"] != DBNull.Value)
                        {
                            DateTime startTime = Convert.ToDateTime(reader["ActualStartTime"]);
                            txtActualStartTime.Text = startTime.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        if (reader["ActualEndTime"] != DBNull.Value)
                        {
                            DateTime endTime = Convert.ToDateTime(reader["ActualEndTime"]);
                            txtActualEndTime.Text = endTime.ToString("yyyy-MM-ddTHH:mm");
                        }
                        
                        if (reader["Downtime"] != DBNull.Value)
                        {
                            decimal downtime = Convert.ToDecimal(reader["Downtime"]);
                            txtDowntime.Text = downtime.ToString("0.00");
                        }
                        
                        // PM Type and Status
                        if (reader["PMType"] != DBNull.Value)
                            ddlPMType.SelectedValue = reader["PMType"].ToString();
                        
                        if (reader["Status"] != DBNull.Value)
                            ddlStatus.SelectedValue = reader["Status"].ToString();
                        
                        // Text fields
                        txtMaintenancePerformed.Text = reader["MaintenancePerformed"] != DBNull.Value ? reader["MaintenancePerformed"].ToString() : "";
                        txtPartsReplaced.Text = reader["PartsReplaced"] != DBNull.Value ? reader["PartsReplaced"].ToString() : "";
                        txtComments.Text = reader["Comments"] != DBNull.Value ? reader["Comments"].ToString() : "";
                        
                        // Performed By
                        if (reader["PerformedBy"] != DBNull.Value)
                        {
                            string performedBy = reader["PerformedBy"].ToString();
                            if (ddlPerformedBy.Items.FindByText(performedBy) != null)
                                ddlPerformedBy.SelectedValue = ddlPerformedBy.Items.FindByText(performedBy).Value;
                        }
                        
                        // Cost
                        if (reader["Cost"] != DBNull.Value)
                            txtCost.Text = reader["Cost"].ToString();
                        
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
                        litPageTitle.Text = string.Format("PM Log #{0}", id);
                        litPageSubtitle.Text = string.Format("Equipment: {0} | Status: {1}", 
                            reader["EquipmentType"] != DBNull.Value ? reader["EquipmentType"].ToString() : "N/A", 
                            status);
                        
                        // Show delete button for existing records
                        btnDelete.Visible = true;
                    }
                    else
                    {
                        ShowMessage("PM log not found.", "error");
                    }
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error loading PM data: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("LoadPMData error: " + ex.Message);
        }
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        // Check permissions for editing (allow new records or edit permission)
        if (!IsNewMode && !CanEdit)
        {
            ShowMessage("You do not have permission to edit PM logs.", "error");
            return;
        }
        
        try
        {
            // Validate required fields
            string validationError = ValidateRequiredFields();
            if (!string.IsNullOrEmpty(validationError))
            {
                ShowMessage(validationError, "error");
                return;
            }
            
            // Parse equipment type and ID from composite value (now that validation passed)
            string[] parts = ddlEquipmentID.SelectedValue.Split('|');
            if (parts.Length != 2)
            {
                ShowMessage("Invalid equipment selection.", "error");
                return;
            }
            string equipmentType = parts[0];
            int equipmentId = int.Parse(parts[1]);
            
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            if (IsNewMode)
            {
                // Get ScheduledDate, EatonID, and EquipmentName from equipment
                DateTime? scheduledDate = null;
                string equipmentEatonID = null;
                string equipmentName = null;
                
                using (var connSched = new SqlConnection(cs))
                using (var cmdSched = new SqlCommand(@"
                    SELECT NextPM, EatonID, EquipmentName 
                    FROM dbo.vw_Equipment_RequirePM 
                    WHERE EquipmentType = @EquipmentType AND EquipmentID = @EquipmentID", connSched))
                {
                    cmdSched.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmdSched.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    connSched.Open();
                    using (var reader = cmdSched.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["NextPM"] != DBNull.Value)
                                scheduledDate = Convert.ToDateTime(reader["NextPM"]);
                            if (reader["EatonID"] != DBNull.Value)
                                equipmentEatonID = reader["EatonID"].ToString();
                            if (reader["EquipmentName"] != DBNull.Value)
                                equipmentName = reader["EquipmentName"].ToString();
                        }
                    }
                }
                
                // INSERT new PM log
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    INSERT INTO dbo.PM_Log (
                        EquipmentType, EquipmentID, EquipmentEatonID, EquipmentName, PMID,
                        ScheduledDate, PMDate, NextPMDate, PMType, 
                        MaintenancePerformed, PerformedBy, PartsReplaced, Cost, 
                        Status, Comments, CreatedBy, AttachmentsPath,
                        ActualStartTime, ActualEndTime, Downtime
                    ) VALUES (
                        @EquipmentType, @EquipmentID, @EquipmentEatonID, @EquipmentName, @PMID,
                        @ScheduledDate, @PMDate, @NextPMDate, @PMType,
                        @MaintenancePerformed, @PerformedBy, @PartsReplaced, @Cost,
                        @Status, @Comments, @CreatedBy, @AttachmentsPath,
                        @ActualStartTime, @ActualEndTime, @Downtime
                    );
                    SELECT SCOPE_IDENTITY();", conn))
                {
                    cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    cmd.Parameters.AddWithValue("@EquipmentEatonID", string.IsNullOrEmpty(equipmentEatonID) ? (object)DBNull.Value : equipmentEatonID);
                    cmd.Parameters.AddWithValue("@EquipmentName", string.IsNullOrEmpty(equipmentName) ? (object)DBNull.Value : equipmentName);
                    cmd.Parameters.AddWithValue("@PMID", DBNull.Value); // Will be updated after getting new ID
                    cmd.Parameters.AddWithValue("@ScheduledDate", scheduledDate.HasValue ? (object)scheduledDate.Value : DBNull.Value);
                    AddPMParameters(cmd);
                    cmd.Parameters.AddWithValue("@CreatedBy", Session["TED:FullName"] != null ? Session["TED:FullName"].ToString() : "");
                    cmd.Parameters.AddWithValue("@AttachmentsPath", ""); // Will be updated after file uploads
                    
                    conn.Open();
                    var newId = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    // Update PMID with proper format after getting the new ID
                    string formattedPMID = string.IsNullOrEmpty(equipmentEatonID) ? null : newId + " _ " + equipmentEatonID;
                    using (var updatePMIDCmd = new SqlCommand("UPDATE dbo.PM_Log SET PMID = @PMID WHERE PMLogID = @PMLogID", conn))
                    {
                        updatePMIDCmd.Parameters.AddWithValue("@PMLogID", newId);
                        updatePMIDCmd.Parameters.AddWithValue("@PMID", string.IsNullOrEmpty(formattedPMID) ? (object)DBNull.Value : formattedPMID);
                        updatePMIDCmd.ExecuteNonQuery();
                    }
                    
                    // Handle file uploads after getting the new ID
                    string attachmentPaths = HandleFileUploads(newId);
                    if (!string.IsNullOrEmpty(attachmentPaths))
                    {
                        // Update with attachment paths
                        using (var updateCmd = new SqlCommand("UPDATE dbo.PM_Log SET AttachmentsPath = @AttachmentsPath WHERE PMLogID = @PMLogID", conn))
                        {
                            updateCmd.Parameters.AddWithValue("@PMLogID", newId);
                            updateCmd.Parameters.AddWithValue("@AttachmentsPath", attachmentPaths);
                            updateCmd.ExecuteNonQuery();
                        }
                    }
                    
                    // Update equipment table with LastPM, LastPMBy, and NextPM
                    UpdateEquipmentPMFields(conn, equipmentType, equipmentId, 
                        DateTime.Parse(txtPMDate.Text), 
                        ddlPerformedBy.SelectedItem.Text,
                        string.IsNullOrEmpty(txtNextPMDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextPMDate.Text));
                    
                    // Create local file system folder for this PM
                    try
                    {
                        if (!string.IsNullOrWhiteSpace(equipmentEatonID))
                        {
                            bool folderCreated = LocalFileSystemService.CreatePMFolder(newId.ToString(), equipmentEatonID);
                            if (!folderCreated)
                            {
                                string error = LocalFileSystemService.GetLastError();
                                System.Diagnostics.Debug.WriteLine("PM folder creation failed: " + error);
                            }
                        }
                    }
                    catch (Exception folderEx)
                    {
                        System.Diagnostics.Debug.WriteLine("PM folder error: " + folderEx.Message);
                    }
                    
                    Response.Redirect(string.Format("PMDetails.aspx?id={0}&msg=created", newId));
                }
            }
            else
            {
                // Get EquipmentEatonID and EquipmentName from equipment for UPDATE
                string equipmentEatonID = null;
                string equipmentName = null;
                
                using (var connEquip = new SqlConnection(cs))
                using (var cmdEquip = new SqlCommand(@"
                    SELECT EatonID, EquipmentName 
                    FROM dbo.vw_Equipment_RequirePM 
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
                
                // UPDATE existing PM log
                using (var conn = new SqlConnection(cs))
                using (var cmd = new SqlCommand(@"
                    UPDATE dbo.PM_Log SET
                        EquipmentType = @EquipmentType,
                        EquipmentID = @EquipmentID,
                        EquipmentEatonID = @EquipmentEatonID,
                        EquipmentName = @EquipmentName,
                        PMID = @PMID,
                        PMDate = @PMDate,
                        NextPMDate = @NextPMDate,
                        PMType = @PMType,
                        MaintenancePerformed = @MaintenancePerformed,
                        PerformedBy = @PerformedBy,
                        PartsReplaced = @PartsReplaced,
                        Cost = @Cost,
                        Status = @Status,
                        Comments = @Comments,
                        AttachmentsPath = @AttachmentsPath,
                        ActualStartTime = @ActualStartTime,
                        ActualEndTime = @ActualEndTime,
                        Downtime = @Downtime
                    WHERE PMLogID = @PMLogID", conn))
                {
                    cmd.Parameters.AddWithValue("@PMLogID", PMLogID.Value);
                    cmd.Parameters.AddWithValue("@EquipmentType", equipmentType);
                    cmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                    cmd.Parameters.AddWithValue("@EquipmentEatonID", string.IsNullOrEmpty(equipmentEatonID) ? (object)DBNull.Value : equipmentEatonID);
                    cmd.Parameters.AddWithValue("@EquipmentName", string.IsNullOrEmpty(equipmentName) ? (object)DBNull.Value : equipmentName);
                    cmd.Parameters.AddWithValue("@PMID", string.IsNullOrEmpty(equipmentEatonID) ? (object)DBNull.Value : PMLogID.Value + " _ " + equipmentEatonID);
                    AddPMParameters(cmd);
                    
                    // Get existing attachments and add new ones
                    string existingAttachments = GetExistingAttachments(PMLogID.Value);
                    string newAttachments = HandleFileUploads(PMLogID.Value);
                    
                    string combinedAttachments = string.IsNullOrEmpty(existingAttachments) 
                        ? newAttachments 
                        : (string.IsNullOrEmpty(newAttachments) 
                            ? existingAttachments 
                            : existingAttachments + "," + newAttachments);
                    
                    cmd.Parameters.AddWithValue("@AttachmentsPath", combinedAttachments ?? "");
                    
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    
                    // Update equipment table with LastPM, LastPMBy, and NextPM
                    UpdateEquipmentPMFields(conn, equipmentType, equipmentId, 
                        DateTime.Parse(txtPMDate.Text), 
                        ddlPerformedBy.SelectedItem.Text,
                        string.IsNullOrEmpty(txtNextPMDate.Text) ? (DateTime?)null : DateTime.Parse(txtNextPMDate.Text));
                }
                
                Response.Redirect(string.Format("PMDetails.aspx?id={0}&msg=updated", PMLogID.Value));
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error saving PM log: " + ex.Message, "error");
            System.Diagnostics.Debug.WriteLine("btnSave_Click error: " + ex.Message);
        }
    }
    
    private void AddPMParameters(SqlCommand cmd)
    {
        cmd.Parameters.AddWithValue("@PMDate", DateTime.Parse(txtPMDate.Text));
        cmd.Parameters.AddWithValue("@NextPMDate", string.IsNullOrEmpty(txtNextPMDate.Text) ? (object)DBNull.Value : DateTime.Parse(txtNextPMDate.Text));
        cmd.Parameters.AddWithValue("@PMType", ddlPMType.SelectedValue);
        cmd.Parameters.AddWithValue("@MaintenancePerformed", txtMaintenancePerformed.Text.Trim());
        cmd.Parameters.AddWithValue("@PerformedBy", ddlPerformedBy.SelectedItem.Text);
        cmd.Parameters.AddWithValue("@PartsReplaced", string.IsNullOrEmpty(txtPartsReplaced.Text) ? (object)DBNull.Value : txtPartsReplaced.Text.Trim());
        
        decimal cost;
        cmd.Parameters.AddWithValue("@Cost", string.IsNullOrEmpty(txtCost.Text) || !decimal.TryParse(txtCost.Text, out cost) ? (object)DBNull.Value : cost);
        
        cmd.Parameters.AddWithValue("@Status", string.IsNullOrEmpty(ddlStatus.SelectedValue) ? (object)DBNull.Value : ddlStatus.SelectedValue);
        cmd.Parameters.AddWithValue("@Comments", string.IsNullOrEmpty(txtComments.Text) ? (object)DBNull.Value : txtComments.Text.Trim());
        
        // New time and downtime fields
        cmd.Parameters.AddWithValue("@ActualStartTime", string.IsNullOrEmpty(txtActualStartTime.Text) ? (object)DBNull.Value : DateTime.Parse(txtActualStartTime.Text));
        cmd.Parameters.AddWithValue("@ActualEndTime", string.IsNullOrEmpty(txtActualEndTime.Text) ? (object)DBNull.Value : DateTime.Parse(txtActualEndTime.Text));
        
        decimal downtime;
        cmd.Parameters.AddWithValue("@Downtime", string.IsNullOrEmpty(txtDowntime.Text) || !decimal.TryParse(txtDowntime.Text, out downtime) ? (object)DBNull.Value : downtime);
    }
    
    private void UpdateEquipmentPMFields(SqlConnection conn, string equipmentType, int equipmentId, DateTime lastPM, string lastPMBy, DateTime? nextPM)
    {
        try
        {
            string tableName = "";
            string idColumn = "";
            string lastPMByColumn = "";
            
            // Determine table name, ID column, and correct LastPMBy column name based on equipment type
            switch (equipmentType)
            {
                case "ATE":
                    tableName = "ATE_Inventory";
                    idColumn = "ATEInventoryID";
                    lastPMByColumn = "LastPMBy";
                    break;
                case "Asset":
                    tableName = "Asset_Inventory";
                    idColumn = "AssetID";
                    lastPMByColumn = "PMBy";
                    break;
                case "Fixture":
                    tableName = "Fixture_Inventory";
                    idColumn = "FixtureID";
                    lastPMByColumn = "PMBy";
                    break;
                case "Harness":
                    tableName = "Harness_Inventory";
                    idColumn = "HarnessID";
                    lastPMByColumn = "PMBy";
                    break;
                default:
                    System.Diagnostics.Debug.WriteLine("UpdateEquipmentPMFields: Unknown equipment type - " + equipmentType);
                    return;
            }
            
            // Build and execute the UPDATE statement
            string updateQuery = string.Format(@"
                UPDATE dbo.{0}
                SET LastPM = @LastPM,
                    {1} = @LastPMBy,
                    NextPM = @NextPM
                WHERE {2} = @EquipmentID", 
                tableName, lastPMByColumn, idColumn);
            
            using (var updateCmd = new SqlCommand(updateQuery, conn))
            {
                updateCmd.Parameters.AddWithValue("@LastPM", lastPM);
                updateCmd.Parameters.AddWithValue("@LastPMBy", lastPMBy);
                updateCmd.Parameters.AddWithValue("@NextPM", nextPM.HasValue ? (object)nextPM.Value : DBNull.Value);
                updateCmd.Parameters.AddWithValue("@EquipmentID", equipmentId);
                
                updateCmd.ExecuteNonQuery();
                System.Diagnostics.Debug.WriteLine(string.Format("Updated {0} ID {1} with LastPM={2}, {3}={4}, NextPM={5}", 
                    tableName, equipmentId, lastPM, lastPMByColumn, lastPMBy, nextPM.HasValue ? nextPM.Value.ToString() : "NULL"));
            }
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("UpdateEquipmentPMFields error: " + ex.Message);
            throw; // Re-throw to ensure transaction rollback if needed
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        // Check permissions for deleting
        if (!CanEdit)
        {
            ShowMessage("You do not have permission to delete PM logs.", "error");
            return;
        }
        
        if (!PMLogID.HasValue) return;
        
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("DELETE FROM dbo.PM_Log WHERE PMLogID = @PMLogID", conn))
            {
                cmd.Parameters.AddWithValue("@PMLogID", PMLogID.Value);
                conn.Open();
                int rowsAffected = cmd.ExecuteNonQuery();
                
                if (rowsAffected > 0)
                {
                    Response.Redirect("PreventiveMaintenance.aspx?deleted=1");
                }
                else
                {
                    ShowMessage("Failed to delete PM log.", "error");
                }
            }
        }
        catch (Exception ex)
        {
            ShowMessage("Error deleting PM log: " + ex.Message, "error");
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
    
    private string ValidateRequiredFields()
    {
        if (string.IsNullOrWhiteSpace(ddlEquipmentID.SelectedValue))
        {
            return "Equipment/Asset selection is required.";
        }
        
        // Note: Equipment parsing is now done at method level after validation
        
        if (string.IsNullOrWhiteSpace(txtPMDate.Text))
        {
            return "PM Date is required.";
        }
        
        if (string.IsNullOrWhiteSpace(ddlPMType.SelectedValue))
        {
            return "PM Type is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtMaintenancePerformed.Text))
        {
            return "Maintenance Performed description is required.";
        }
        
        if (string.IsNullOrWhiteSpace(ddlPerformedBy.SelectedValue))
        {
            return "Performed By is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtActualStartTime.Text))
        {
            return "Actual Start Time is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtActualEndTime.Text))
        {
            return "Actual End Time is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtDowntime.Text))
        {
            return "Downtime is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtNextPMDate.Text))
        {
            return "Next PM Date is required.";
        }
        
        if (string.IsNullOrWhiteSpace(ddlStatus.SelectedValue))
        {
            return "Status is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtPartsReplaced.Text))
        {
            return "Parts Replaced is required.";
        }
        
        if (string.IsNullOrWhiteSpace(txtCost.Text))
        {
            return "Cost is required.";
        }
        
        return null; // No validation errors
    }

    private string HandleFileUploads(int logId)
    {
        if (!fileUpload.HasFiles)
            return string.Empty;
        
        try
        {
            // Get the PM folder path - always use Storage folder
            string equipmentEatonID = GetEquipmentEatonIDForPM(logId);
            string uploadFolder = LocalFileSystemService.GetPMFolderPath(logId.ToString(), equipmentEatonID ?? "Unknown");
            
            // If folder doesn't exist, try to create it
            if (string.IsNullOrEmpty(uploadFolder))
            {
                bool folderCreated = LocalFileSystemService.CreatePMFolder(logId.ToString(), equipmentEatonID ?? "Unknown");
                if (folderCreated)
                {
                    uploadFolder = LocalFileSystemService.GetPMFolderPath(logId.ToString(), equipmentEatonID ?? "Unknown");
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
                    savedFiles.Add(string.Format("Storage/PM Logs/{0}_{1}/{2}", logId, LocalFileSystemService.SanitizeFolderName(equipmentEatonID ?? "Unknown"), fileName));
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
            using (var cmd = new SqlCommand("SELECT AttachmentsPath FROM dbo.PM_Log WHERE PMLogID = @PMLogID", conn))
            {
                cmd.Parameters.AddWithValue("@PMLogID", logId);
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
            if (canEdit && PMLogID.HasValue)
            {
                html.AppendFormat(@"
                    <a href='?id={0}&deleteAttachment={1}' class='delete-btn' onclick='return confirm(""Are you sure you want to delete this attachment?"");' title='Delete attachment'>
                        <svg class='icon' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2.5' stroke-linecap='round'>
                            <line x1='18' y1='6' x2='6' y2='18'/>
                            <line x1='6' y1='6' x2='18' y2='18'/>
                        </svg>
                    </a>", 
                    PMLogID.Value,
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
            using (var cmd = new SqlCommand("UPDATE dbo.PM_Log SET AttachmentsPath = @AttachmentsPath WHERE PMLogID = @PMLogID", conn))
            {
                cmd.Parameters.AddWithValue("@PMLogID", logId);
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
    
    private string GetEquipmentEatonIDForPM(int logId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT EquipmentEatonID FROM dbo.PM_Log WHERE PMLogID = @PMLogID", conn))
            {
                cmd.Parameters.AddWithValue("@PMLogID", logId);
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
