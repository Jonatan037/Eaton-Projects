using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.IO;
using System.Drawing;
using System.Drawing.Imaging;
using System.Linq;

public partial class TED_Settings : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Check authentication using the correct session keys
            if (Session["TED:UserID"] == null)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

            try
            {
                LoadUserData();
                LoadSidebarData();
            }
            catch (Exception ex)
            {
                // Log the error for debugging
                System.Diagnostics.Debug.WriteLine("Settings Page Error: " + ex.Message);
                Response.Write("Error loading settings: " + ex.Message);
            }
        }
    }

    private void LoadSidebarData()
    {
        try
        {
            // Use session data directly for sidebar
            string fullName = Session["TED:FullName"] as string ?? "";
            string jobRole = Session["TED:JobRole"] as string ?? "User";
            string profilePicture = Session["TED:ProfilePath"] as string ?? "";

            if (litSidebarFullName != null) litSidebarFullName.Text = Server.HtmlEncode(fullName);
            if (litSidebarRole != null) litSidebarRole.Text = Server.HtmlEncode(jobRole);

            if (!string.IsNullOrEmpty(profilePicture))
            {
                if (imgSidebarAvatar != null)
                {
                    imgSidebarAvatar.ImageUrl = profilePicture;
                    imgSidebarAvatar.Visible = true;
                }
                if (avatarSidebarFallback != null)
                {
                    avatarSidebarFallback.Visible = false;
                }
            }
            else
            {
                if (litSidebarInitials != null) litSidebarInitials.Text = GetInitials(fullName);
                if (imgSidebarAvatar != null) imgSidebarAvatar.Visible = false;
                if (avatarSidebarFallback != null) avatarSidebarFallback.Visible = true;
            }

            // Show/hide admin portal link
            string userCategory = Session["TED:UserCategory"] as string ?? "";
            if (lnkAdminPortal != null)
            {
                lnkAdminPortal.Visible = (userCategory.Equals("Admin", StringComparison.OrdinalIgnoreCase));
            }
        }
        catch (Exception ex)
        {
            string errorDetails = "LoadSidebarData Error: " + ex.Message;
            if (ex.InnerException != null)
            {
                errorDetails += " | Inner: " + ex.InnerException.Message;
            }
            errorDetails += " | Stack: " + ex.StackTrace;
            
            System.Diagnostics.Debug.WriteLine(errorDetails);
            ShowError("Error loading sidebar: " + ex.Message);
        }
    }

    private void LoadUserData()
    {
        try
        {
            // Check if connection string exists
            if (ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"] == null)
            {
                throw new Exception("Connection string 'TestEngineeringConnectionString' not found in web.config");
            }
            
            string connString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            
            if (string.IsNullOrEmpty(connString))
            {
                throw new Exception("Connection string is empty");
            }
            
            // Check if session has UserID
            if (Session["TED:UserID"] == null)
            {
                throw new Exception("Session TED:UserID is null");
            }
            
            int userId = Convert.ToInt32(Session["TED:UserID"]);

            if (userId == 0)
            {
                Response.Redirect("~/Account/Login.aspx");
                return;
            }

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = @"
                SELECT 
                    u.FullName, 
                    u.ENumber, 
                    u.Email, 
                    u.Department, 
                    u.JobRole, 
                    u.UserCategory,
                    u.ProfilePicture,
                    u.TestLine
                FROM Users u
                WHERE u.UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);

                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    if (reader.Read())
                    {
                        string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "";
                        string eNumber = reader["ENumber"] != DBNull.Value ? reader["ENumber"].ToString() : "";
                        string email = reader["Email"] != DBNull.Value ? reader["Email"].ToString() : "";
                        string department = reader["Department"] != DBNull.Value ? reader["Department"].ToString() : "Not Set";
                        string jobRole = reader["JobRole"] != DBNull.Value ? reader["JobRole"].ToString() : "Not Set";
                        string userCategory = reader["UserCategory"] != DBNull.Value ? reader["UserCategory"].ToString() : "Not Set";
                        string profilePicture = reader["ProfilePicture"] != DBNull.Value ? reader["ProfilePicture"].ToString() : "";
                        string testLine = reader["TestLine"] != DBNull.Value ? reader["TestLine"].ToString() : "";

                        // Profile header - with null checks
                        if (litFullName != null) litFullName.Text = Server.HtmlEncode(fullName);
                        if (litJobRole != null) litJobRole.Text = Server.HtmlEncode(jobRole);
                        if (litDepartment != null) litDepartment.Text = Server.HtmlEncode(department);
                        if (litUserCategory != null) litUserCategory.Text = Server.HtmlEncode(userCategory);

                        // Info fields - with null checks
                        if (litFullNameValue != null) litFullNameValue.Text = Server.HtmlEncode(fullName);
                        if (litENumber != null) litENumber.Text = Server.HtmlEncode(eNumber);
                        if (litEmail != null) litEmail.Text = Server.HtmlEncode(email);
                        if (litDepartmentValue != null) litDepartmentValue.Text = Server.HtmlEncode(department);
                        if (litJobRoleValue != null) litJobRoleValue.Text = Server.HtmlEncode(jobRole);
                        if (litUserCategoryValue != null) litUserCategoryValue.Text = Server.HtmlEncode(userCategory);

                        // Test Lines - convert IDs to names
                        if (litTestLines != null)
                        {
                            if (!string.IsNullOrEmpty(testLine))
                            {
                                litTestLines.Text = GetTestLineNames(testLine, connString);
                            }
                            else
                            {
                                litTestLines.Text = "Not Assigned";
                            }
                        }

                        // Set initial values for edit mode
                        if (txtFullName != null) txtFullName.Text = fullName;

                        // Profile picture
                        if (imgProfilePic != null && !string.IsNullOrEmpty(profilePicture))
                        {
                            imgProfilePic.ImageUrl = profilePicture;
                        }

                        // Generate initials for fallback
                        if (litInitials != null) litInitials.Text = GetInitials(fullName);
                    }
                    else
                    {
                        ShowError("User data not found.");
                    }

                    reader.Close();
                }
                catch (Exception ex)
                {
                    ShowError("Error loading user data: " + ex.Message);
                }
            }
        }
        }
        catch (Exception ex)
        {
            string errorDetails = "LoadUserData Error: " + ex.Message;
            if (ex.InnerException != null)
            {
                errorDetails += " | Inner: " + ex.InnerException.Message;
            }
            errorDetails += " | Stack: " + ex.StackTrace;
            
            System.Diagnostics.Debug.WriteLine(errorDetails);
            ShowError("Error in LoadUserData: " + ex.Message + (ex.InnerException != null ? " (Inner: " + ex.InnerException.Message + ")" : ""));
        }
    }

    private string GetTestLineNames(string testLineIds, string connString)
    {
        if (string.IsNullOrEmpty(testLineIds))
            return "Not Assigned";

        string[] ids = testLineIds.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        if (ids.Length == 0)
            return "Not Assigned";

        var names = new System.Collections.Generic.List<string>();

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = "SELECT LineName FROM ProductionLine WHERE LineID IN (" + string.Join(",", ids) + ") AND IsActive = 1 ORDER BY LineName";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                try
                {
                    conn.Open();
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read())
                    {
                        names.Add(reader["LineName"].ToString());
                    }

                    reader.Close();
                }
                catch
                {
                    return testLineIds; // Return IDs if query fails
                }
            }
        }

        return names.Count > 0 ? string.Join(", ", names) : "Not Assigned";
    }

    private string GetInitials(string fullName)
    {
        if (string.IsNullOrWhiteSpace(fullName))
            return "U";

        var parts = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        
        if (parts.Length == 1)
        {
            return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
        }
        else if (parts.Length >= 2)
        {
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
        }

        return "U";
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        int userId = Session["TED:UserID"] != null ? Convert.ToInt32(Session["TED:UserID"]) : 0;
        string fullName = txtFullName.Text.Trim();
        string oldPassword = txtOldPassword.Text.Trim();
        string newPassword = txtNewPassword.Text.Trim();
        string confirmPassword = txtConfirmPassword.Text.Trim();

        if (userId == 0)
        {
            Response.Redirect("~/Account/Login.aspx");
            return;
        }

        if (string.IsNullOrEmpty(fullName))
        {
            ShowError("Full name cannot be empty.");
            return;
        }

        // If user is trying to change password
        bool changingPassword = !string.IsNullOrEmpty(newPassword) || !string.IsNullOrEmpty(oldPassword);
        
        if (changingPassword)
        {
            if (string.IsNullOrEmpty(oldPassword))
            {
                ShowError("Please enter your current password.");
                return;
            }
            
            if (string.IsNullOrEmpty(newPassword))
            {
                ShowError("Please enter a new password.");
                return;
            }
            
            if (newPassword != confirmPassword)
            {
                ShowError("New passwords do not match.");
                return;
            }
            
            if (newPassword.Length < 6)
            {
                ShowError("Password must be at least 6 characters.");
                return;
            }
            
            // Verify old password is correct
            if (!VerifyCurrentPassword(userId, oldPassword))
            {
                ShowError("Current password is incorrect.");
                return;
            }
        }

        string connString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = "UPDATE Users SET FullName = @FullName";
            
            // Only update password if user is changing it
            if (changingPassword)
            {
                query += ", Password = @Password";
            }
            
            query += " WHERE UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@FullName", fullName);
                cmd.Parameters.AddWithValue("@UserID", userId);
                
                if (changingPassword)
                {
                    cmd.Parameters.AddWithValue("@Password", newPassword);
                }

                try
                {
                    conn.Open();
                    int rowsAffected = cmd.ExecuteNonQuery();

                    if (rowsAffected > 0)
                    {
                        // Update session if full name changed
                        Session["TED:FullName"] = fullName;
                        
                        // Reload data
                        LoadUserData();
                        
                        // Show success message via client script
                        ScriptManager.RegisterStartupScript(this, GetType(), "saveSuccess", 
                            "showToast('Profile updated successfully!', 'success'); cancelEdit();", true);
                    }
                    else
                    {
                        ShowError("No changes were made.");
                    }
                }
                catch (Exception ex)
                {
                    ShowError("Error updating profile: " + ex.Message);
                }
            }
        }
    }

    private bool VerifyCurrentPassword(int userId, string password)
    {
        string connString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = "SELECT COUNT(*) FROM Users WHERE UserID = @UserID AND Password = @Password";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                cmd.Parameters.AddWithValue("@Password", password);

                try
                {
                    conn.Open();
                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
                catch
                {
                    return false;
                }
            }
        }
    }

    protected void btnUploadPhoto_Click(object sender, EventArgs e)
    {
        if (!fileProfilePic.HasFile)
        {
            ShowError("Please select an image to upload.");
            return;
        }

        int userId = Session["TED:UserID"] != null ? Convert.ToInt32(Session["TED:UserID"]) : 0;
        string eNumber = Session["TED:ENumber"] as string ?? "";
        
        if (userId == 0)
        {
            Response.Redirect("~/Account/Login.aspx");
            return;
        }

        HttpPostedFile uploadedFile = fileProfilePic.PostedFile;

        // Validate file type
        string fileExtension = Path.GetExtension(uploadedFile.FileName).ToLower();
        if (fileExtension != ".jpg" && fileExtension != ".jpeg" && fileExtension != ".png")
        {
            ShowError("Only JPG and PNG files are allowed.");
            return;
        }

        // Validate file size (5MB max)
        if (uploadedFile.ContentLength > 5 * 1024 * 1024)
        {
            ShowError("File size must not exceed 5MB.");
            return;
        }

        try
        {
            // Get the base application physical path
            string appPhysicalPath = Server.MapPath("~/");
            
            // Build the uploads folder path
            string uploadsFolder = Path.Combine(appPhysicalPath, "Uploads", "ProfilePictures");
            
            // Ensure directory exists
            if (!Directory.Exists(uploadsFolder))
            {
                Directory.CreateDirectory(uploadsFolder);
            }

            // Generate unique filename using same pattern as RequestAccount
            string baseName = string.IsNullOrEmpty(eNumber) ? "profile" : eNumber;
            var sbn = new System.Text.StringBuilder(baseName.Length);
            for (int i = 0; i < baseName.Length; i++)
            {
                char c = baseName[i];
                if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-')
                    sbn.Append(c);
            }
            baseName = sbn.Length > 0 ? sbn.ToString() : "profile";
            string stamp = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff");
            string finalFileName = baseName + "_" + stamp + fileExtension;

            // Build full physical path
            string savedProfilePhysicalPath = Path.Combine(uploadsFolder, finalFileName);
            
            // Debug: Log the paths
            System.Diagnostics.Debug.WriteLine("appPhysicalPath: " + appPhysicalPath);
            System.Diagnostics.Debug.WriteLine("uploadsFolder: " + uploadsFolder);
            System.Diagnostics.Debug.WriteLine("savedProfilePhysicalPath: " + savedProfilePhysicalPath);
            
            // Save file directly
            fileProfilePic.SaveAs(savedProfilePhysicalPath);

            // Build app-relative path for database storage (without leading ~/)
            string savedProfileRelPath = "Uploads/ProfilePictures/" + finalFileName;

            // Update database with relative path
            UpdateProfilePicture(userId, savedProfileRelPath);

            // Delete old profile picture if exists
            DeleteOldProfilePicture(userId, savedProfileRelPath);
            
            // Update session with full app-relative path
            Session["TED:ProfilePath"] = "~/" + savedProfileRelPath;

            // Reload data
            LoadUserData();
            LoadSidebarData();

            // Show success message
            ScriptManager.RegisterStartupScript(this, GetType(), "uploadSuccess", 
                "showToast('Profile picture updated successfully!', 'success'); closePhotoModal(); setTimeout(function() { location.reload(); }, 1500);", true);
        }
        catch (Exception ex)
        {
            System.Diagnostics.Debug.WriteLine("Upload Error: " + ex.Message + " | " + ex.StackTrace);
            ShowError("Error uploading image: " + ex.Message + (ex.InnerException != null ? " - Inner: " + ex.InnerException.Message : ""));
        }
    }

    private Bitmap ResizeImage(System.Drawing.Image image, int width, int height)
    {
        var destRect = new Rectangle(0, 0, width, height);
        var destImage = new Bitmap(width, height);

        destImage.SetResolution(image.HorizontalResolution, image.VerticalResolution);

        using (var graphics = Graphics.FromImage(destImage))
        {
            graphics.CompositingMode = System.Drawing.Drawing2D.CompositingMode.SourceCopy;
            graphics.CompositingQuality = System.Drawing.Drawing2D.CompositingQuality.HighQuality;
            graphics.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            graphics.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;

            using (var wrapMode = new ImageAttributes())
            {
                wrapMode.SetWrapMode(System.Drawing.Drawing2D.WrapMode.TileFlipXY);
                graphics.DrawImage(image, destRect, 0, 0, image.Width, image.Height, GraphicsUnit.Pixel, wrapMode);
            }
        }

        return destImage;
    }

    private ImageFormat GetImageFormat(string extension)
    {
        switch (extension.ToLower())
        {
            case ".png":
                return ImageFormat.Png;
            case ".jpg":
            case ".jpeg":
                return ImageFormat.Jpeg;
            default:
                return ImageFormat.Jpeg;
        }
    }

    private void UpdateProfilePicture(int userId, string imagePath)
    {
        string connString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = "UPDATE Users SET ProfilePicture = @ProfilePicture WHERE UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@ProfilePicture", imagePath);
                cmd.Parameters.AddWithValue("@UserID", userId);

                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
    }

    private void DeleteOldProfilePicture(int userId, string newPath)
    {
        string connString = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;

        using (SqlConnection conn = new SqlConnection(connString))
        {
            string query = "SELECT ProfilePicture FROM Users WHERE UserID = @UserID";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);

                conn.Open();
                object result = cmd.ExecuteScalar();

                if (result != null && result != DBNull.Value)
                {
                    string oldPath = result.ToString();
                    
                    if (!string.IsNullOrEmpty(oldPath) && oldPath != newPath)
                    {
                        string physicalPath = Server.MapPath(oldPath);
                        
                        if (File.Exists(physicalPath))
                        {
                            try
                            {
                                File.Delete(physicalPath);
                            }
                            catch
                            {
                                // Ignore deletion errors
                            }
                        }
                    }
                }
            }
        }
    }

    private void ShowError(string message)
    {
        ScriptManager.RegisterStartupScript(this, GetType(), "showError", 
            "showToast('" + message.Replace("'", "\\'") + "', 'error');", true);
    }
}
