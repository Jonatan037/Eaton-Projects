using System;
using System.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;

public partial class TED_Admin_CreateUser : Page
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
        // Sidebar active
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "create", null);
        }
        if (!IsPostBack)
        {
            // Populate dropdowns from database
            BindDropDowns();
            
            // Register production lines data for client-side
            RegisterProductionLinesScript();
            
            // Edit mode if userId is provided
            int userId;
            if (int.TryParse(Request.QueryString["userId"], out userId))
            {
                // Only override header title in edit mode
                var header = FindControl("AdminHeader1");
                if (header != null)
                {
                    var prop = header.GetType().GetProperty("Title");
                    if (prop != null) prop.SetValue(header, "Edit User", null);
                }
                LoadUser(userId);
                if (pnlEditing != null) pnlEditing.Visible = true;
            }
            // Prefill from Approve flow if present
            txtFullName.Text = (Session["TED:PrefillUser:FullName"] as string) ?? string.Empty;
            txtENumber.Text = (Session["TED:PrefillUser:ENumber"] as string) ?? string.Empty;
            txtEmail.Text = (Session["TED:PrefillUser:Email"] as string) ?? string.Empty;
            var preRole = (Session["TED:PrefillUser:JobRole"] as string) ?? string.Empty;
            SetDropDownOrText("ddlJobRole", "txtJobRole", preRole);
            var preDept = (Session["TED:PrefillUser:Department"] as string) ?? string.Empty;
            SetDropDownOrText("ddlDepartment", "txtDepartment", preDept);
            // Assigned User Role from Approve action (Category)
            var assignedCategory = Session["TED:PrefillUser:AssignedCategory"] as string;
            if (!string.IsNullOrWhiteSpace(assignedCategory) && ddlCategory != null)
            {
                var item = ddlCategory.Items.FindByText(assignedCategory) ?? ddlCategory.Items.FindByValue(assignedCategory);
                if (item == null)
                {
                    ddlCategory.Items.Add(new ListItem(assignedCategory, assignedCategory));
                    item = ddlCategory.Items.FindByValue(assignedCategory);
                }
                if (item != null) ddlCategory.SelectedValue = item.Value;
            }
            // Clear after read to avoid reuse
            Session.Remove("TED:PrefillUser:FullName");
            Session.Remove("TED:PrefillUser:ENumber");
            Session.Remove("TED:PrefillUser:Email");
            Session.Remove("TED:PrefillUser:JobRole");
            Session.Remove("TED:PrefillUser:Department");
            Session.Remove("TED:PrefillUser:AssignedCategory");
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        // If editing, keep 'Edit User'; otherwise the markup Title remains 'Create User Form'.
        int userId;
        if (int.TryParse(Request.QueryString["userId"], out userId))
        {
            var header = FindControl("AdminHeader1");
            if (header != null)
            {
                var prop = header.GetType().GetProperty("Title");
                if (prop != null) prop.SetValue(header, "Edit User", null);
            }
        }
    }

    protected void btnCreate_Click(object sender, EventArgs e)
    {
        try
        {
            int userId;
            if (int.TryParse(Request.QueryString["userId"], out userId))
            {
                UpdateUser(userId);
                // Log admin: user updated
                TryLogAdminAction("dbo.Users", userId.ToString(), txtFullName.Text, "User Updated", string.Empty, txtFullName.Text, "Modified");
                lblMsg.Text = string.Empty; // no inline label
                // Success toast
                try
                {
                    var sm = ScriptManager.GetCurrent(this.Page);
                    if (sm != null) ScriptManager.RegisterStartupScript(this, this.GetType(), "toastUpd", "window.showToast('User updated','success');", true);
                    else ClientScript.RegisterStartupScript(this.GetType(), "toastUpd", "window.showToast('User updated','success');", true);
                }
                catch { }
                ResetForm();
                return;
            }
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                // Discover available columns to avoid errors if optional columns don't exist
                var available = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                using (var check = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Users'", conn))
                using (var rdr = check.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        available.Add(rdr.GetString(0));
                    }
                }

                var cols = new List<string>();
                var vals = new List<string>();
                var cmd = new SqlCommand();
                cmd.Connection = conn;

                // Required/common columns
                cols.Add("FullName"); vals.Add("@FullName"); cmd.Parameters.AddWithValue("@FullName", (object)(txtFullName.Text ?? string.Empty));
                cols.Add("ENumber");  vals.Add("@ENumber");  cmd.Parameters.AddWithValue("@ENumber", (object)(txtENumber.Text ?? string.Empty));
                
                // Email - only required for E numbers, not for C numbers
                var eNumber = txtENumber.Text ?? string.Empty;
                var email = txtEmail.Text ?? string.Empty;
                var isContractor = eNumber.Trim().ToUpper().StartsWith("C");
                if (isContractor)
                {
                    // Auto-populate email with CNumber@eaton.com for contractors to avoid UNIQUE constraint issues
                    email = eNumber.Trim() + "@eaton.com";
                }
                cols.Add("Email");    vals.Add("@Email");    cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : (object)email);

                // Password (store as plain text per requirement)
                string pwdSource = null;
                if (txtTempPassword != null && !string.IsNullOrWhiteSpace(txtTempPassword.Text))
                    pwdSource = txtTempPassword.Text;
                else
                    pwdSource = "Temp123!"; // Default temporary password
                cols.Add("Password"); vals.Add("@Password"); cmd.Parameters.AddWithValue("@Password", pwdSource);

                // Normalize UI selection to DB-allowed categories
                var normalizedCategory = MapCategoryToDbAllowed(ddlCategory.SelectedValue);
                cols.Add("UserCategory"); vals.Add("@UserCategory"); cmd.Parameters.AddWithValue("@UserCategory", normalizedCategory);
                cols.Add("IsActive");     vals.Add("@IsActive");     cmd.Parameters.AddWithValue("@IsActive", true); // Always active for new users
                cols.Add("CreatedDate");  vals.Add("GETDATE()" );     // inline value
                cols.Add("CreatedBy");    vals.Add("@CreatedBy");    cmd.Parameters.AddWithValue("@CreatedBy", (Session["TED:FullName"] as string) ?? User.Identity.Name ?? "Admin");
                cols.Add("JobRole");      vals.Add("@JobRole");      cmd.Parameters.AddWithValue("@JobRole", (object)(GetSelectedOrText("ddlJobRole", "txtJobRole")));

                // Optional fields only if present
                // Always persist Department
                cols.Add("Department"); vals.Add("@Department"); cmd.Parameters.AddWithValue("@Department", (object) GetSelectedOrText("ddlDepartment", "txtDepartment"));
                if (available.Contains("Phone"))      { cols.Add("Phone");      vals.Add("@Phone");      cmd.Parameters.AddWithValue("@Phone", (object)(txtPhone != null ? txtPhone.Text : string.Empty)); }
                if (available.Contains("Site"))       { cols.Add("Site");       vals.Add("@Site");       cmd.Parameters.AddWithValue("@Site", (object)(txtSite != null ? txtSite.Text : string.Empty)); }
                if (available.Contains("Manager"))    { cols.Add("Manager");    vals.Add("@Manager");    cmd.Parameters.AddWithValue("@Manager", (object)(txtManager != null ? txtManager.Text : string.Empty)); }
                
                // Handle TestLine multi-select
                if (available.Contains("TestLine"))
                {
                    var testLines = GetSelectedTestLines();
                    cols.Add("TestLine"); vals.Add("@TestLine"); cmd.Parameters.AddWithValue("@TestLine", testLines ?? string.Empty);
                }

                // Optional profile picture upload storing relative path
                string relProfilePath = null;
                try
                {
                    if (fuProfile != null && fuProfile.HasFile)
                    {
                        // Save where avatar discovery looks: Uploads/ProfilePictures
                        var root = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
                        var subfolder = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
                        var ext = Path.GetExtension(fuProfile.FileName);
                        if (string.IsNullOrWhiteSpace(ext)) ext = ".png";
                        var fileName = (txtENumber.Text ?? Path.GetFileNameWithoutExtension(fuProfile.FileName)).Replace(" ", "_") + ext;
                        var rel = root.TrimEnd('/') + "/" + subfolder.Trim('/') + "/" + fileName;
                        var abs = Server.MapPath(rel);
                        var dir = Path.GetDirectoryName(abs);
                        if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                        fuProfile.SaveAs(abs);
                        relProfilePath = rel;
                    }
                }
                catch { relProfilePath = null; }
                if (!string.IsNullOrWhiteSpace(relProfilePath))
                {
                    if (available.Contains("ProfilePath")) { cols.Add("ProfilePath"); vals.Add("@ProfilePath"); cmd.Parameters.AddWithValue("@ProfilePath", relProfilePath); }
                    if (available.Contains("ProfilePicture")) { cols.Add("ProfilePicture"); vals.Add("@ProfilePicture"); cmd.Parameters.AddWithValue("@ProfilePicture", relProfilePath); }
                }

                cmd.CommandText = "INSERT INTO dbo.Users(" + string.Join(",", cols) + ") VALUES(" + string.Join(",", vals) + ")";
                cmd.ExecuteNonQuery();
            }
            // Log admin: new user created
            TryLogAdminAction("dbo.Users", (txtENumber.Text ?? string.Empty), txtFullName.Text, "User Created", string.Empty, txtFullName.Text, "New");
            lblMsg.Text = string.Empty; // no inline label
            try
            {
                var sm = ScriptManager.GetCurrent(this.Page);
                if (sm != null) ScriptManager.RegisterStartupScript(this, this.GetType(), "toastNew", "window.showToast('User created','success');", true);
                else ClientScript.RegisterStartupScript(this.GetType(), "toastNew", "window.showToast('User created','success');", true);
            }
            catch { }
            ResetForm();
            // Re-register the production lines script to reinitialize the Test Line dropdown
            RegisterProductionLinesScript();
        }
        catch (Exception ex)
        {
            lblMsg.Text = "Error: " + ex.Message;
        }
    }

    private void BindDropDowns()
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        {
            conn.Open();
            
            // Load Departments
            using (var cmd = new SqlCommand("SELECT Department FROM dbo.Department WHERE IsActive = 1 ORDER BY SortOrder, Department", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    ddlDepartment.Items.Add(reader["Department"].ToString());
                }
            }
            
            // Load Job Roles
            using (var cmd = new SqlCommand("SELECT Role FROM dbo.JobRole WHERE IsActive = 1 ORDER BY SortOrder, Role", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    ddlJobRole.Items.Add(reader["Role"].ToString());
                }
            }
            
            // Load User Categories
            using (var cmd = new SqlCommand("SELECT Category FROM dbo.UserCategory WHERE IsActive = 1 ORDER BY SortOrder, Category", conn))
            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    ddlCategory.Items.Add(reader["Category"].ToString());
                }
            }
        }
    }

    private void LoadUser(int userId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT TOP 1 * FROM dbo.Users WHERE UserID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", userId);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        txtFullName.Text = rdr["FullName"].ToString();
                        txtENumber.Text = rdr["ENumber"].ToString();
                        txtEmail.Text = rdr["Email"].ToString();
                        SetDropDownOrText("ddlJobRole", "txtJobRole", rdr["JobRole"].ToString());
                        if (HasColumn(rdr, "Department")) SetDropDownOrText("ddlDepartment", "txtDepartment", rdr["Department"].ToString());
                        if (HasColumn(rdr, "Phone")) txtPhone.Text = rdr["Phone"].ToString();
                        if (HasColumn(rdr, "Site")) txtSite.Text = rdr["Site"].ToString();
                        if (HasColumn(rdr, "Manager")) txtManager.Text = rdr["Manager"].ToString();
                        
                        // Handle TestLine for edit mode
                        if (HasColumn(rdr, "TestLine"))
                        {
                            var testLines = rdr["TestLine"].ToString();
                            RegisterTestLineEditScript(testLines);
                        }
                        
                        var cat = rdr["UserCategory"].ToString();
                        var item = ddlCategory.Items.FindByText(cat);
                        if (item != null) ddlCategory.SelectedValue = cat;
                    }
                }
            }
        }
        catch { }
    }

    private void UpdateUser(int userId)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        {
            conn.Open();
            // Discover columns
            var available = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            using (var check = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Users'", conn))
            using (var rdr = check.ExecuteReader())
            {
                while (rdr.Read()) available.Add(rdr.GetString(0));
            }

            var sets = new System.Text.StringBuilder();
            var cmd = new SqlCommand();
            cmd.Connection = conn;

            Action<string, string, object> add = (col, param, val) => { if (sets.Length > 0) sets.Append(", "); sets.Append(col + "=" + param); cmd.Parameters.AddWithValue(param, val ?? string.Empty); };
            add("FullName", "@FullName", txtFullName.Text);
            add("ENumber", "@ENumber", txtENumber.Text);
            
            // Email - only required for E numbers, not for C numbers
            var eNumber = txtENumber.Text ?? string.Empty;
            var email = txtEmail.Text ?? string.Empty;
            var isContractor = eNumber.Trim().ToUpper().StartsWith("C");
            if (isContractor)
            {
                email = eNumber.Trim() + "@eaton.com"; // Auto-populate contractor email
            }
            add("Email", "@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : (object)email);
            
            add("UserCategory", "@UserCategory", MapCategoryToDbAllowed(ddlCategory.SelectedValue));
            add("JobRole", "@JobRole", GetSelectedOrText("ddlJobRole", "txtJobRole"));
            // Always persist Department
            add("Department", "@Department", GetSelectedOrText("ddlDepartment", "txtDepartment"));
            if (available.Contains("Phone")) add("Phone", "@Phone", txtPhone != null ? txtPhone.Text : null);
            if (available.Contains("Site")) add("Site", "@Site", txtSite != null ? txtSite.Text : null);
            if (available.Contains("Manager")) add("Manager", "@Manager", txtManager != null ? txtManager.Text : null);
            
            // Handle TestLine multi-select for update
            if (available.Contains("TestLine"))
            {
                var testLines = GetSelectedTestLines();
                add("TestLine", "@TestLine", testLines ?? string.Empty);
            }

            // Optional: change password if provided
            if (txtTempPassword != null && !string.IsNullOrWhiteSpace(txtTempPassword.Text))
            {
                // Store plain text per requirement
                add("Password", "@Password", txtTempPassword.Text);
            }

            // Optional: new profile upload
            string relProfilePath = null;
            try
            {
                if (fuProfile != null && fuProfile.HasFile)
                {
                    var root = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
                    var subfolder = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
                    var ext = Path.GetExtension(fuProfile.FileName); if (string.IsNullOrWhiteSpace(ext)) ext = ".png";
                    var fileName = (txtENumber.Text ?? Path.GetFileNameWithoutExtension(fuProfile.FileName)).Replace(" ", "_") + ext;
                    var rel = root.TrimEnd('/') + "/" + subfolder.Trim('/') + "/" + fileName;
                    var abs = Server.MapPath(rel);
                    var dir = Path.GetDirectoryName(abs); if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
                    fuProfile.SaveAs(abs);
                    relProfilePath = rel;
                }
            }
            catch { relProfilePath = null; }
            if (!string.IsNullOrWhiteSpace(relProfilePath))
            {
                if (available.Contains("ProfilePath")) add("ProfilePath", "@ProfilePath", relProfilePath);
                if (available.Contains("ProfilePicture")) add("ProfilePicture", "@ProfilePicture", relProfilePath);
            }

            cmd.CommandText = "UPDATE dbo.Users SET " + sets.ToString() + " WHERE UserID=@id";
            cmd.Parameters.AddWithValue("@id", userId);
            cmd.ExecuteNonQuery();
        }
    }

    private bool HasColumn(System.Data.IDataRecord rdr, string col)
    {
        for (int i = 0; i < rdr.FieldCount; i++) if (string.Equals(rdr.GetName(i), col, StringComparison.OrdinalIgnoreCase)) return true;
        return false;
    }

    private string GetSelectedOrText(string dropdownId, string textboxId)
    {
        var ddl = FindControl(dropdownId) as DropDownList;
        if (ddl != null) return (ddl.SelectedValue ?? string.Empty).Trim();
        var tb = FindControl(textboxId) as TextBox;
        return tb != null ? (tb.Text ?? string.Empty).Trim() : string.Empty;
    }

    private void SetDropDownOrText(string dropdownId, string textboxId, string value)
    {
        value = value ?? string.Empty;
        var ddl = FindControl(dropdownId) as DropDownList;
        if (ddl != null)
        {
            var item = ddl.Items.FindByText(value) ?? ddl.Items.FindByValue(value);
            if (item == null && !string.IsNullOrWhiteSpace(value))
            {
                ddl.Items.Add(new ListItem(value, value));
                item = ddl.Items.FindByValue(value);
            }
            if (item != null) ddl.SelectedValue = item.Value;
            return;
        }
        var tb = FindControl(textboxId) as TextBox;
        if (tb != null) tb.Text = value;
    }

    private string Sha256Hex(string value)
    {
        using (var sha = System.Security.Cryptography.SHA256.Create())
        {
            var bytes = sha.ComputeHash(System.Text.Encoding.UTF8.GetBytes(value));
            return BitConverter.ToString(bytes).Replace("-", string.Empty).ToLowerInvariant();
        }
    }

    private string MapCategoryToDbAllowed(string uiValue)
    {
        // Normalize UI options to DB-allowed categories:
        // Admin, Test Engineering, Quality, Tester, Viewer
        var v = (uiValue ?? "").Trim();
        if (v.Equals("Admin", StringComparison.OrdinalIgnoreCase)) return "Admin";
        if (v.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase)) return "Test Engineering";
        if (v.Equals("Quality", StringComparison.OrdinalIgnoreCase)) return "Quality";
        if (v.Equals("Tester", StringComparison.OrdinalIgnoreCase)) return "Tester";
        if (v.Equals("Viewer", StringComparison.OrdinalIgnoreCase)) return "Viewer";
        // Back-compat with older UI terms
        if (v.Equals("Engineer", StringComparison.OrdinalIgnoreCase)) return "Test Engineering";
        if (v.Equals("Technician", StringComparison.OrdinalIgnoreCase)) return "Tester";
        if (v.Equals("Supervisor", StringComparison.OrdinalIgnoreCase)) return "Viewer";
        // Fallback: lowest-privilege generic
        return "Viewer";
    }

    private void ResetForm()
    {
        try
        {
            if (pnlEditing != null && pnlEditing.Visible)
            {
                // In edit mode, we keep fields, but the user asked to clear after success, so clear anyway
            }
            txtFullName.Text = string.Empty;
            txtENumber.Text = string.Empty;
            txtEmail.Text = string.Empty;
            if (ddlDepartment != null && ddlDepartment.Items.Count > 0) ddlDepartment.SelectedIndex = 0;
            if (ddlJobRole != null && ddlJobRole.Items.Count > 0) ddlJobRole.SelectedIndex = 0;
            if (txtTempPassword != null) txtTempPassword.Text = string.Empty;
            // Clear file upload is not possible server-side; user must re-select file
            if (ddlCategory != null && ddlCategory.Items.Count > 0) ddlCategory.SelectedIndex = 0;
            lblMsg.Text = string.Empty;
        }
        catch { }
    }

    private void TryLogAdminAction(string table, string recordId, string recordName, string field, string oldVal, string newVal, string changeType)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"INSERT INTO Change_Log (TableName, RecordID, RecordName, ChangedBy, ChangeDate, FieldName, OldValue, NewValue, ChangeType, CreatedDate)
                                             VALUES (@t,@id,@rn,@by,GETDATE(),@f,@ov,@nv,@ct,GETDATE())", conn))
            {
                cmd.Parameters.AddWithValue("@t", table ?? string.Empty);
                int rid; int.TryParse(recordId ?? string.Empty, out rid);
                cmd.Parameters.AddWithValue("@id", rid);
                cmd.Parameters.AddWithValue("@rn", recordName ?? string.Empty);
                cmd.Parameters.AddWithValue("@by", (Session["TED:FullName"] as string) ?? User.Identity.Name ?? "Admin");
                cmd.Parameters.AddWithValue("@f", field ?? string.Empty);
                cmd.Parameters.AddWithValue("@ov", oldVal ?? string.Empty);
                cmd.Parameters.AddWithValue("@nv", newVal ?? string.Empty);
                var ct = changeType ?? string.Empty; if (string.Equals(ct, "New", StringComparison.OrdinalIgnoreCase)) ct = "Created"; cmd.Parameters.AddWithValue("@ct", ct);
                conn.Open(); cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private void RegisterProductionLinesScript()
    {
        try
        {
            var productionLines = GetProductionLines();
            var jsArray = new System.Text.StringBuilder();
            jsArray.Append("[");
            
            for (int i = 0; i < productionLines.Rows.Count; i++)
            {
                if (i > 0) jsArray.Append(",");
                var row = productionLines.Rows[i];
                jsArray.AppendFormat("{{\"id\":\"{0}\",\"name\":\"{1}\"}}", 
                    row["ProductionLineID"], 
                    System.Web.HttpUtility.JavaScriptStringEncode(row["ProductionLineName"].ToString()));
            }
            
            jsArray.Append("]");
            
            var script = "window.productionLinesData = " + jsArray.ToString() + ";";
            
            ClientScript.RegisterStartupScript(this.GetType(), "ProductionLinesData", script, true);
        }
        catch (Exception ex)
        {
            // Fallback to empty array if there's an error
            ClientScript.RegisterStartupScript(this.GetType(), "ProductionLinesData", "window.productionLinesData = [];", true);
        }
    }

    private DataTable GetProductionLines()
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT ProductionLineID, ProductionLineName FROM ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName", conn))
        {
            conn.Open();
            using (var adapter = new SqlDataAdapter(cmd))
            {
                var table = new DataTable();
                adapter.Fill(table);
                return table;
            }
        }
    }

    private string GetSelectedTestLines()
    {
        var selectedIds = new List<string>();
        
        // Look for hidden inputs in the form data that match the pattern
        foreach (string key in Request.Form.Keys)
        {
            if (key != null && key.StartsWith("msTestLine_") && !key.EndsWith("_options"))
            {
                // The value itself is the ProductionLineID
                var value = Request.Form[key];
                if (!string.IsNullOrEmpty(value))
                {
                    selectedIds.Add(value);
                }
            }
        }
        
        return selectedIds.Count > 0 ? string.Join(",", selectedIds) : string.Empty;
    }

    private void RegisterTestLineEditScript(string testLines)
    {
        if (string.IsNullOrEmpty(testLines)) return;
        
        var selectedIds = testLines.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                                   .Select(id => id.Trim())
                                   .Where(id => !string.IsNullOrEmpty(id))
                                   .ToArray();
        
        if (selectedIds.Length > 0)
        {
            var jsArray = "[" + string.Join(",", selectedIds.Select(id => "\"" + System.Web.HttpUtility.JavaScriptStringEncode(id) + "\"")) + "]";
            var script = string.Format(@"
                setTimeout(function() {{
                    var selectedIds = {0};
                    selectedIds.forEach(function(id) {{
                        var checkbox = document.getElementById('msTestLine_' + id);
                        if (checkbox) checkbox.checked = true;
                    }});
                    updateMultiSelectButton('msTestLine_button', 'msTestLine_options');
                }}, 200);", jsArray);
            
            ClientScript.RegisterStartupScript(this.GetType(), "PreSelectTestLines", script, true);
        }
    }
}
