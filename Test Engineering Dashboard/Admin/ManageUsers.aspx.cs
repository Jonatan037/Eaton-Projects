using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Linq;

public partial class TED_Admin_ManageUsers : Page
{
    private int PageIndex
    {
        get { return (int)(ViewState["PageIndex"] ?? 0); }
        set { ViewState["PageIndex"] = value; }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        // Admin-only gate
        var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
        var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
        if (!(cat.Contains("admin") || role.Contains("admin")))
        {
            Response.Redirect("~/UnauthorizedAccess.aspx");
            return;
        }
        if (!IsPostBack)
        {
            PopulateFilterDropdowns();
            ddlSort.SelectedValue = "IDDesc"; // Set default sort to ID descending
            BindUsers();
        }
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Users Manager", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "manage", null);
        }
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlSort_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlDepartmentFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlJobRoleFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void ddlUserCategoryFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        PageIndex = 0;
        BindUsers();
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        if (PageIndex > 0) PageIndex--;
        BindUsers();
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        PageIndex++;
        BindUsers();
    }

    protected void gridUsers_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        if (e.CommandName == "Edit")
        {
            var id = e.CommandArgument.ToString();
            Response.Redirect("~/Admin/CreateUser.aspx?userId=" + Server.UrlEncode(id));
        }
        else if (e.CommandName == "Toggle")
        {
            var arg = e.CommandArgument.ToString();
            var parts = arg.Split(':');
            if (parts.Length == 2)
            {
                var userId = parts[0];
                var isActive = parts[1].ToLowerInvariant() == "true";
                ToggleActive(userId, !isActive);
                // Log admin: user activation toggled
                TryLogAdminAction("dbo.Users", userId, null, "IsActive", isActive ? "1" : "0", (!isActive) ? "1" : "0", "Modified");
                BindUsers();
            }
        }
        else if (e.CommandName == "Save")
        {
            var row = (e.CommandSource as Control).NamingContainer as GridViewRow;
            if (row != null)
            {
                var userId = gridUsers.DataKeys[row.RowIndex].Value.ToString();
                var txtName = row.FindControl("txtFullNameRow") as TextBox;
                var txtEmail = row.FindControl("txtEmailRow") as TextBox;
                var txtPassword = row.FindControl("txtPasswordRow") as TextBox;
                var ddlDept = row.FindControl("ddlDepartmentRow") as DropDownList;
                var ddlRole = row.FindControl("ddlJobRoleRow") as DropDownList;
                var ddlCat = row.FindControl("ddlCategoryRow") as DropDownList;
                var chkStatus = row.FindControl("chkStatusRow") as CheckBox;
                var lblMsg = row.FindControl("lblRowMsg") as Label;

                var name = txtName != null ? txtName.Text.Trim() : string.Empty;
                var email = txtEmail != null ? txtEmail.Text.Trim() : string.Empty;
                var password = txtPassword != null ? txtPassword.Text : string.Empty;
                var dept = ddlDept != null ? ddlDept.SelectedValue : string.Empty;
                var role = ddlRole != null ? ddlRole.SelectedValue : string.Empty;
                var cat = ddlCat != null ? ddlCat.SelectedValue : string.Empty;
                var isActive = chkStatus != null && chkStatus.Checked;
                
                // Get selected test lines from multi-select dropdown
                var testLines = GetMultiSelectTestLines("msTestLine_" + userId);

                // Validation: required Name and Email, basic Email format
                string error = null;
                if (string.IsNullOrWhiteSpace(name)) error = "Name is required.";
                else if (string.IsNullOrWhiteSpace(email)) error = "Email is required.";
                else if (!IsValidEmail(email)) error = "Email format is not valid.";

                if (error != null)
                {
                    if (lblMsg != null)
                    {
                        lblMsg.Text = error;
                        lblMsg.CssClass = "row-msg error";
                        lblMsg.Visible = true;
                    }
                    return;
                }

                try
                {
                    var modifiedBy = Session["TED:ENumber"] as string ?? string.Empty;
                    SaveInline(userId, name, email, dept, role, cat, isActive, password, testLines, modifiedBy);
                    // Log admin: user modified inline
                    TryLogAdminAction("dbo.Users", userId, name, "User Updated", string.Empty, name, "Modified");
                    // Use a global toast instead of per-row label for success
                    var sm = ScriptManager.GetCurrent(this.Page);
                    if (sm != null)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "toastSaved", "window.showToast('User saved', 'success');", true);
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "toastSaved", "window.showToast('User saved', 'success');", true);
                    }
                    ViewState["JustSavedUserID"] = null; // ensure no per-row success
                    BindUsers();
                }
                catch (Exception ex)
                {
                    if (lblMsg != null)
                    {
                        lblMsg.Text = "Save failed: " + ex.Message;
                        lblMsg.CssClass = "row-msg error";
                        lblMsg.Visible = true;
                    }
                    return;
                }
            }
        }
        else if (e.CommandName == "RemoveUser")
        {
            var id = e.CommandArgument.ToString();
            // Log before delete
            TryLogAdminAction("dbo.Users", id, null, "User Deleted", id, string.Empty, "Deleted");
            DeleteUser(id);
            // Optional toast feedback
            try
            {
                var sm = ScriptManager.GetCurrent(this.Page);
                if (sm != null) ScriptManager.RegisterStartupScript(this, this.GetType(), "toastDel", "window.showToast('User deleted','success');", true);
                else ClientScript.RegisterStartupScript(this.GetType(), "toastDel", "window.showToast('User deleted','success');", true);
            }
            catch { }
            BindUsers();
        }
    }

    protected void btnUploadUserPhoto_Click(object sender, EventArgs e)
    {
        try
        {
            var userId = hdnSelectedUserId.Value;
            if (string.IsNullOrWhiteSpace(userId))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('No user selected','error');", true);
                return;
            }

            if (!fileUserPhoto.HasFile)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('Please select a file','error');", true);
                return;
            }

            var file = fileUserPhoto.PostedFile;
            var maxSize = 5 * 1024 * 1024; // 5MB
            if (file.ContentLength > maxSize)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('File size exceeds 5MB limit','error');", true);
                return;
            }

            var allowedExts = new[] { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };
            var ext = Path.GetExtension(file.FileName).ToLowerInvariant();
            if (!allowedExts.Contains(ext))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('Invalid file type. Use JPG, PNG, GIF, BMP, or WEBP','error');", true);
                return;
            }

            // Get user's ENumber for filename
            var eNumber = GetUserENumber(userId);
            if (string.IsNullOrWhiteSpace(eNumber))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('User ENumber not found','error');", true);
                return;
            }

            // Delete old profile picture if exists
            DeleteOldProfilePicture(userId);

            // Save new profile picture
            var root = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
            var sub = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
            var virtFolder = root.TrimEnd('/') + "/" + sub.Trim('/') + "/";
            var absFolder = Server.MapPath(virtFolder);

            if (!Directory.Exists(absFolder))
            {
                Directory.CreateDirectory(absFolder);
            }

            var timestamp = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff");
            var fileName = eNumber + "_" + timestamp + ext;
            var absPath = Path.Combine(absFolder, fileName);
            var virtPath = virtFolder + fileName;

            // Save file directly without resizing
            file.SaveAs(absPath);

            // Update database
            UpdateUserProfilePath(userId, virtPath);

            // Log the change
            TryLogAdminAction("dbo.Users", userId, null, "ProfilePath", string.Empty, virtPath, "Modified");

            ClientScript.RegisterStartupScript(this.GetType(), "photoSuccess", "closePhotoModal(); window.showToast('Profile picture updated','success'); setTimeout(function(){ location.reload(); }, 1500);", true);
        }
        catch (Exception ex)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('Upload failed: " + ex.Message.Replace("'", "\\'") + "','error');", true);
        }
    }

    protected void btnRemoveUserPhoto_Click(object sender, EventArgs e)
    {
        try
        {
            var userId = hdnSelectedUserId.Value;
            if (string.IsNullOrWhiteSpace(userId))
            {
                ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('No user selected','error');", true);
                return;
            }

            // Get user info for logging
            var userName = GetUserName(userId);

            // Delete old profile picture file if exists
            DeleteOldProfilePicture(userId);

            // Update database to remove profile path
            UpdateUserProfilePath(userId, "");

            // Log the change
            TryLogAdminAction("dbo.Users", userId, userName, "ProfilePath", "removed", "", "Modified");

            ClientScript.RegisterStartupScript(this.GetType(), "photoSuccess", "closePhotoModal(); window.showToast('Profile picture removed','success'); setTimeout(function(){ location.reload(); }, 1500);", true);
        }
        catch (Exception ex)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "photoError", "window.showToast('Remove failed: " + ex.Message.Replace("'", "\\'") + "','error');", true);
        }
    }

    private string GetUserENumber(string userId)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT ENumber FROM dbo.Users WHERE UserID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            var result = cmd.ExecuteScalar();
            return result != null ? result.ToString() : string.Empty;
        }
    }

    private string GetUserName(string userId)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT FullName FROM dbo.Users WHERE UserID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            var result = cmd.ExecuteScalar();
            return result != null ? result.ToString() : string.Empty;
        }
    }

    private void UpdateUserProfilePath(string userId, string profilePath)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("UPDATE dbo.Users SET ProfilePath=@p WHERE UserID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@p", profilePath);
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void DeleteOldProfilePicture(string userId)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand("SELECT ProfilePath FROM dbo.Users WHERE UserID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", userId);
                conn.Open();
                var oldPath = cmd.ExecuteScalar() as string;
                if (!string.IsNullOrWhiteSpace(oldPath))
                {
                    var absPath = Server.MapPath(oldPath);
                    if (File.Exists(absPath))
                    {
                        File.Delete(absPath);
                    }
                }
            }
        }
        catch { }
    }

    private void SaveInline(string userId, string name, string email, string department, string jobRole, string userCategory, bool isActive, string password, string testLine, string modifiedBy)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand())
        {
            var sql = "UPDATE dbo.Users SET FullName=@n, Email=@e, Department=@d, JobRole=@r, UserCategory=@c, IsActive=@a, TestLine=@tl, ModifiedDate=GETDATE(), ModifiedBy=@mb";
            if (!string.IsNullOrWhiteSpace(password)) sql += ", Password=@p";
            sql += " WHERE UserID=@id";
            cmd.CommandText = sql;
            cmd.Connection = conn;
            cmd.Parameters.AddWithValue("@n", name);
            cmd.Parameters.AddWithValue("@e", email);
            cmd.Parameters.AddWithValue("@d", department);
            cmd.Parameters.AddWithValue("@r", jobRole);
            cmd.Parameters.AddWithValue("@c", userCategory);
            cmd.Parameters.AddWithValue("@a", isActive);
            cmd.Parameters.AddWithValue("@tl", testLine ?? string.Empty);
            cmd.Parameters.AddWithValue("@mb", modifiedBy);
            if (!string.IsNullOrWhiteSpace(password)) cmd.Parameters.AddWithValue("@p", password);
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private bool IsValidEmail(string email)
    {
        try
        {
            var addr = new System.Net.Mail.MailAddress(email);
            return addr.Address == email;
        }
        catch { return false; }
    }

    private void ToggleActive(string userId, bool makeActive)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("UPDATE dbo.Users SET IsActive=@a WHERE UserID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@a", makeActive);
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void DeleteUser(string userId)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("DELETE FROM dbo.Users WHERE UserID=@id", conn))
        {
            cmd.Parameters.AddWithValue("@id", userId);
            conn.Open();
            cmd.ExecuteNonQuery();
        }
    }

    private void PopulateFilterDropdowns()
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        {
            conn.Open();
            
            // Populate Department dropdown
            using (var cmd = new SqlCommand("SELECT DepartmentID, Department FROM dbo.Department WHERE IsActive = 1 ORDER BY SortOrder, Department", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    ddlDepartmentFilter.Items.Add(new ListItem(rdr["Department"].ToString(), rdr["Department"].ToString()));
                }
            }
            
            // Populate Job Role dropdown
            using (var cmd = new SqlCommand("SELECT JobRoleID, Role FROM dbo.JobRole WHERE IsActive = 1 ORDER BY SortOrder, Role", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    ddlJobRoleFilter.Items.Add(new ListItem(rdr["Role"].ToString(), rdr["Role"].ToString()));
                }
            }
            
            // Populate User Category dropdown
            using (var cmd = new SqlCommand("SELECT UserCategoryID, Category FROM dbo.UserCategory WHERE IsActive = 1 ORDER BY SortOrder, Category", conn))
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    ddlUserCategoryFilter.Items.Add(new ListItem(rdr["Category"].ToString(), rdr["Category"].ToString()));
                }
            }
        }
    }

    private void BindUsers()
    {
        var pageSize = 10;
        int.TryParse(ddlPageSize.SelectedValue, out pageSize);
        var search = (txtSearch.Text ?? string.Empty).Trim();
        var status = ddlStatus.SelectedValue;
        var departmentFilter = ddlDepartmentFilter.SelectedValue;
        var jobRoleFilter = ddlJobRoleFilter.SelectedValue;
        var userCategoryFilter = ddlUserCategoryFilter.SelectedValue;

        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand())
        {
            cmd.Connection = conn;
            cmd.CommandText = "SELECT UserID, FullName, ENumber, Email, Password, Department, JobRole, IsActive, ProfilePath, CreatedDate, UserCategory, ModifiedDate, ModifiedBy, TestLine FROM dbo.Users WHERE 1=1";
            if (!string.IsNullOrEmpty(search))
            {
                cmd.CommandText += " AND (FullName LIKE @q OR ENumber LIKE @q OR Email LIKE @q OR Department LIKE @q OR JobRole LIKE @q)";
                cmd.Parameters.AddWithValue("@q", "%" + search + "%");
            }
            if (status == "Active") cmd.CommandText += " AND IsActive = 1";
            else if (status == "Inactive") cmd.CommandText += " AND IsActive = 0";
            
            if (!string.IsNullOrEmpty(departmentFilter))
            {
                cmd.CommandText += " AND Department = @dept";
                cmd.Parameters.AddWithValue("@dept", departmentFilter);
            }
            
            if (!string.IsNullOrEmpty(jobRoleFilter))
            {
                cmd.CommandText += " AND JobRole = @role";
                cmd.Parameters.AddWithValue("@role", jobRoleFilter);
            }
            
            if (!string.IsNullOrEmpty(userCategoryFilter))
            {
                cmd.CommandText += " AND UserCategory = @cat";
                cmd.Parameters.AddWithValue("@cat", userCategoryFilter);
            }

            string orderBy = "UserID DESC";
            var sort = ddlSort.SelectedValue;
            if (string.Equals(sort, "IDDesc", StringComparison.OrdinalIgnoreCase)) orderBy = "UserID DESC";
            else if (string.Equals(sort, "IDAsc", StringComparison.OrdinalIgnoreCase)) orderBy = "UserID ASC";
            else if (string.Equals(sort, "Name", StringComparison.OrdinalIgnoreCase)) orderBy = "FullName";
            else if (string.Equals(sort, "ENumber", StringComparison.OrdinalIgnoreCase)) orderBy = "ENumber";
            else if (string.Equals(sort, "Department", StringComparison.OrdinalIgnoreCase)) orderBy = "Department, FullName";
            cmd.CommandText += " ORDER BY " + orderBy + " OFFSET @off ROWS FETCH NEXT @ps ROWS ONLY; SELECT COUNT(1) FROM dbo.Users WHERE 1=1";
            if (!string.IsNullOrEmpty(search)) cmd.CommandText += " AND (FullName LIKE @q OR ENumber LIKE @q OR Email LIKE @q OR Department LIKE @q OR JobRole LIKE @q)";
            if (status == "Active") cmd.CommandText += " AND IsActive = 1";
            else if (status == "Inactive") cmd.CommandText += " AND IsActive = 0";
            
            if (!string.IsNullOrEmpty(departmentFilter)) cmd.CommandText += " AND Department = @dept";
            if (!string.IsNullOrEmpty(jobRoleFilter)) cmd.CommandText += " AND JobRole = @role";
            if (!string.IsNullOrEmpty(userCategoryFilter)) cmd.CommandText += " AND UserCategory = @cat";

            cmd.Parameters.AddWithValue("@off", PageIndex * pageSize);
            cmd.Parameters.AddWithValue("@ps", pageSize);

            conn.Open();
            var table = new DataTable();
            var total = 0;
            
            using (var rdr = cmd.ExecuteReader())
            {
                // Manually load the first result set to avoid consuming both result sets
                table.Load(rdr);
                
                // Now try to get the count from the second result set
                // But table.Load() has already consumed it, so we need a different approach
                total = table.Rows.Count; // Temporary: use actual row count
            }
            
            // Get the real total count by running a separate query
            using (var countCmd = new SqlCommand())
            {
                countCmd.Connection = conn;
                countCmd.CommandText = "SELECT COUNT(1) FROM dbo.Users WHERE 1=1";
                if (!string.IsNullOrEmpty(search))
                {
                    countCmd.CommandText += " AND (FullName LIKE @q OR ENumber LIKE @q OR Email LIKE @q OR Department LIKE @q OR JobRole LIKE @q)";
                    countCmd.Parameters.AddWithValue("@q", "%" + search + "%");
                }
                if (status == "Active") countCmd.CommandText += " AND IsActive = 1";
                else if (status == "Inactive") countCmd.CommandText += " AND IsActive = 0";
                
                if (!string.IsNullOrEmpty(departmentFilter))
                {
                    countCmd.CommandText += " AND Department = @dept";
                    countCmd.Parameters.AddWithValue("@dept", departmentFilter);
                }
                
                if (!string.IsNullOrEmpty(jobRoleFilter))
                {
                    countCmd.CommandText += " AND JobRole = @role";
                    countCmd.Parameters.AddWithValue("@role", jobRoleFilter);
                }
                
                if (!string.IsNullOrEmpty(userCategoryFilter))
                {
                    countCmd.CommandText += " AND UserCategory = @cat";
                    countCmd.Parameters.AddWithValue("@cat", userCategoryFilter);
                }
                
                total = (int)countCmd.ExecuteScalar();
            }
            
            // DEBUG: Show what we got
            Response.Write(string.Format("<!-- DEBUG: DataTable has {0} rows, total = {1} -->", table.Rows.Count, total));
            
            foreach (DataRow row in table.Rows)
            {
                var rel = (row["ProfilePath"] as string) ?? string.Empty;
                row["ProfilePath"] = rel;
            }
            
            lblPagination.Text = string.Format("Showing {0}-{1} of {2}", 
                PageIndex * pageSize + 1, 
                Math.Min((PageIndex + 1) * pageSize, total), 
                total);
            
            // Update button states with CSS classes
            btnPrev.Enabled = PageIndex > 0;
            btnPrev.CssClass = PageIndex > 0 ? "pagination-btn" : "pagination-btn disabled";
            
            btnNext.Enabled = (PageIndex + 1) * pageSize < total;
            btnNext.CssClass = (PageIndex + 1) * pageSize < total ? "pagination-btn" : "pagination-btn disabled";

                // Project additional fields for UI
                if (!table.Columns.Contains("ProfileThumbUrl")) table.Columns.Add("ProfileThumbUrl", typeof(string));
                if (!table.Columns.Contains("ActiveText")) table.Columns.Add("ActiveText", typeof(string));
                // Ensure new grid columns exist even if not present in DB result
                if (!table.Columns.Contains("CreatedAt")) table.Columns.Add("CreatedAt", typeof(DateTime));
                if (!table.Columns.Contains("UserCategory")) table.Columns.Add("UserCategory", typeof(string));
                if (!table.Columns.Contains("ModifiedAt")) table.Columns.Add("ModifiedAt", typeof(DateTime));
                if (!table.Columns.Contains("ModifiedBy")) table.Columns.Add("ModifiedBy", typeof(string));
                if (!table.Columns.Contains("TestLine")) table.Columns.Add("TestLine", typeof(string));

                // Use exact known sources from DB
                string createdSource = table.Columns.Contains("CreatedDate") ? "CreatedDate" : null;
                string categorySource = table.Columns.Contains("UserCategory") ? "UserCategory" : null;
                string modifiedSource = table.Columns.Contains("ModifiedDate") ? "ModifiedDate" : null;
                string modifiedBySource = table.Columns.Contains("ModifiedBy") ? "ModifiedBy" : null;
                foreach (DataRow r in table.Rows)
                {
                    var p = r["ProfilePath"] as string ?? string.Empty;
                    var en = r.Table.Columns.Contains("ENumber") ? (r["ENumber"] != DBNull.Value ? r["ENumber"].ToString() : string.Empty) : string.Empty;
                    // Try to resolve explicit path, else infer by ENumber
                    r["ProfileThumbUrl"] = ResolveThumbUrlOrFind(p, en);
                    var active = false; bool.TryParse(r["IsActive"].ToString(), out active);
                    r["ActiveText"] = active ? "Active" : "Inactive";

                    // Populate CreatedAt
                    if (createdSource != null)
                    {
                        var srcVal = r[createdSource];
                        if (srcVal != null && srcVal != DBNull.Value)
                        {
                            DateTime dt;
                            if (srcVal is DateTime) dt = (DateTime)srcVal; else DateTime.TryParse(srcVal.ToString(), out dt);
                            if (dt != default(DateTime)) r["CreatedAt"] = dt;
                        }
                    }

                    // Populate UserCategory
                    if (categorySource != null)
                    {
                        var catVal = r[categorySource];
                        if (catVal != null && catVal != DBNull.Value)
                        {
                            r["UserCategory"] = catVal.ToString();
                        }
                    }

                    // Populate ModifiedAt/ModifiedBy
                    if (modifiedSource != null)
                    {
                        var mVal = r[modifiedSource];
                        if (mVal != null && mVal != DBNull.Value)
                        {
                            DateTime mdt;
                            if (mVal is DateTime) mdt = (DateTime)mVal; else DateTime.TryParse(mVal.ToString(), out mdt);
                            if (mdt != default(DateTime)) r["ModifiedAt"] = mdt;
                        }
                    }
                    if (modifiedBySource != null)
                    {
                        var mb = r[modifiedBySource];
                        if (mb != null && mb != DBNull.Value) r["ModifiedBy"] = mb.ToString();
                    }
                }

                gridUsers.DataSource = table;
                gridUsers.DataBind();
            }
        
        // Pass production lines data to client-side
        RegisterProductionLinesScript();
        
        // Set title (redundant on postbacks but harmless)
        var header = FindControl("AdminHeader1") as UserControl;
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Users Manager", null);
        }
    }

    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        var header = FindControl("AdminHeader1") as UserControl;
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Users Manager", null);
        }
    }

    protected void gridUsers_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            var img = e.Row.FindControl("imgAvatar") as Image;
            var pnl = e.Row.FindControl("pnlInitials") as Panel;
            var lit = e.Row.FindControl("litInitials") as Literal;
            var data = e.Row.DataItem as DataRowView;
            if (img != null && pnl != null && lit != null && data != null)
            {
                var name = (data["FullName"] as string) ?? string.Empty;
                lit.Text = GetInitials(name);
                bool showFallback = true;
                try
                {
                    var url = img.ImageUrl;
                    if (!string.IsNullOrWhiteSpace(url))
                    {
                        var abs = Server.MapPath(System.Web.HttpUtility.UrlDecode(url));
                        if (System.IO.File.Exists(abs)) showFallback = false;
                    }
                }
                catch { showFallback = true; }
                img.Attributes["onerror"] = "this.style.display='none'; if(this.nextElementSibling){ this.nextElementSibling.style.display='flex'; }";
                img.Attributes["onload"] = "if(this.naturalWidth>0 && this.naturalHeight>0){ this.style.display='block'; if(this.nextElementSibling){ this.nextElementSibling.style.display='none'; } }";
                img.Visible = true; pnl.Visible = true;
                var imgStyle = img.Attributes["style"] ?? string.Empty;
                var pnlStyle = pnl.Attributes["style"] ?? string.Empty;
                if (showFallback)
                {
                    if (imgStyle.IndexOf("display", StringComparison.OrdinalIgnoreCase) < 0) imgStyle += ";display:none;";
                    if (pnlStyle.IndexOf("display", StringComparison.OrdinalIgnoreCase) < 0) pnlStyle += ";display:flex;";
                }
                else
                {
                    if (imgStyle.IndexOf("display", StringComparison.OrdinalIgnoreCase) < 0) imgStyle += ";display:block;";
                    if (pnlStyle.IndexOf("display", StringComparison.OrdinalIgnoreCase) < 0) pnlStyle += ";display:none;";
                }
                img.Attributes["style"] = imgStyle; pnl.Attributes["style"] = pnlStyle;
            }

            // Preselect inline editor controls
            var txtName = e.Row.FindControl("txtFullNameRow") as TextBox;
            var txtEmail = e.Row.FindControl("txtEmailRow") as TextBox;
            var ddlDept = e.Row.FindControl("ddlDepartmentRow") as DropDownList;
            var ddlRole = e.Row.FindControl("ddlJobRoleRow") as DropDownList;
            var ddlCat = e.Row.FindControl("ddlCategoryRow") as DropDownList;
            var chkStatus = e.Row.FindControl("chkStatusRow") as CheckBox;
            var txtPwd = e.Row.FindControl("txtPasswordRow") as TextBox;
            var lblMsg = e.Row.FindControl("lblRowMsg") as Label;
            
            // Populate dropdowns from database
            PopulateRowDropdowns(ddlDept, ddlRole, ddlCat);
            
            if (data != null)
            {
                if (txtName != null) txtName.Text = data["FullName"].ToString();
                if (txtEmail != null) txtEmail.Text = data["Email"].ToString();
                if (txtPwd != null && data.DataView.Table.Columns.Contains("Password"))
                {
                    var pwdVal = data["Password"].ToString();
                    // For TextMode=Password, WebForms does not render Text by default; set value attribute explicitly
                    txtPwd.Text = pwdVal;
                    try { txtPwd.Attributes["value"] = pwdVal; } catch {}
                }
                if (ddlDept != null)
                {
                    var item = ddlDept.Items.FindByText(data["Department"].ToString());
                    if (item != null) ddlDept.SelectedValue = item.Value;
                }
                if (ddlRole != null)
                {
                    var item = ddlRole.Items.FindByText(data["JobRole"].ToString());
                    if (item != null) ddlRole.SelectedValue = item.Value;
                }
                if (ddlCat != null)
                {
                    var item = ddlCat.Items.FindByText(data["UserCategory"].ToString());
                    if (item != null) ddlCat.SelectedValue = item.Value;
                }
                if (chkStatus != null)
                {
                    var isActive = false; bool.TryParse(data["IsActive"].ToString(), out isActive);
                    chkStatus.Checked = isActive;
                }
                
                // Store TestLine data for client-side population
                var userId = data["UserID"].ToString();
                var testLines = data["TestLine"] != null ? data["TestLine"].ToString() : string.Empty;
                
                // Add the test line data as a data attribute on the row for client-side processing
                e.Row.Attributes["data-userid"] = userId;
                e.Row.Attributes["data-testlines"] = testLines;

                // No per-row success message anymore; global toast handles it.
            }
        }
    }

    private void PopulateRowDropdowns(DropDownList ddlDept, DropDownList ddlRole, DropDownList ddlCat)
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        {
            conn.Open();
            
            // Populate Department dropdown
            if (ddlDept != null)
            {
                ddlDept.Items.Clear();
                using (var cmd = new SqlCommand("SELECT Department FROM dbo.Department WHERE IsActive = 1 ORDER BY SortOrder, Department", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlDept.Items.Add(reader["Department"].ToString());
                    }
                }
            }
            
            // Populate Job Role dropdown
            if (ddlRole != null)
            {
                ddlRole.Items.Clear();
                using (var cmd = new SqlCommand("SELECT Role FROM dbo.JobRole WHERE IsActive = 1 ORDER BY SortOrder, Role", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlRole.Items.Add(reader["Role"].ToString());
                    }
                }
            }
            
            // Populate User Category dropdown
            if (ddlCat != null)
            {
                ddlCat.Items.Clear();
                using (var cmd = new SqlCommand("SELECT Category FROM dbo.UserCategory WHERE IsActive = 1 ORDER BY SortOrder, Category", conn))
                using (var reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ddlCat.Items.Add(reader["Category"].ToString());
                    }
                }
            }
        }
    }

    private string GetInitials(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) return "?";
        var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
        return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpperInvariant();
    }

    private string ResolveThumbUrl(string profilePath)
    {
        if (!string.IsNullOrWhiteSpace(profilePath))
        {
            return ResolveUrl(profilePath);
        }
        return ResolveUrl("~/Images/Users/default-avatar.png");
    }

    private string ResolveThumbUrlOrFind(string rel, string eNumber)
    {
        // If explicit relative path is present and exists, use it
        if (!string.IsNullOrWhiteSpace(rel))
        {
            try
            {
                var abs = Server.MapPath(rel);
                if (File.Exists(abs)) return System.Web.HttpUtility.UrlPathEncode(ResolveUrl(rel));
            }
            catch { }
        }
        // Attempt to infer by scanning uploads/profile pictures for files starting with ENumber
        try
        {
            var root = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
            var sub = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
            var virtFolder = root.TrimEnd('/') + "/" + sub.Trim('/') + "/";
            var absFolder = Server.MapPath(virtFolder);
            if (!string.IsNullOrWhiteSpace(eNumber) && Directory.Exists(absFolder))
            {
                var en = eNumber.Trim();
                var exts = new[] { ".jpg", ".jpeg", ".png", ".webp", ".gif", ".bmp" };
                // Exact ENumber.*
                foreach (var ext in exts)
                {
                    var candidate = Path.Combine(absFolder, en + ext);
                    try { if (File.Exists(candidate)) return System.Web.HttpUtility.UrlPathEncode(ResolveUrl(virtFolder + en + ext)); } catch { }
                }
                // Prefix ENumber_* or ENumber-*
                try
                {
                    var enLower = en.ToLowerInvariant();
                    var best = Directory.EnumerateFiles(absFolder)
                        .Where(f => {
                            try
                            {
                                var name = Path.GetFileName(f);
                                if (string.IsNullOrEmpty(name)) return false;
                                var lower = name.ToLowerInvariant();
                                if (!(lower.StartsWith(enLower + "_") || lower.StartsWith(enLower + "-"))) return false;
                                return exts.Any(x => lower.EndsWith(x));
                            }
                            catch { return false; }
                        })
                        .OrderByDescending(f => { try { return File.GetLastWriteTimeUtc(f); } catch { return DateTime.MinValue; } })
                        .FirstOrDefault();
                    if (!string.IsNullOrEmpty(best)) return System.Web.HttpUtility.UrlPathEncode(ResolveUrl(virtFolder + Path.GetFileName(best)));
                }
                catch { }
            }
        }
        catch { }
        // No image found; returning null lets initials fallback render
        return null;
    }

    private DataTable GetProductionLines()
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT ProductionLineID, ProductionLineName FROM dbo.ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName", conn))
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

    private string GetMultiSelectTestLines(string baseName)
    {
        var selectedIds = new List<string>();
        
        // Look for hidden inputs in the form data that match the pattern
        foreach (string key in Request.Form.Keys)
        {
            if (key != null && key.StartsWith(baseName + "_"))
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
}
