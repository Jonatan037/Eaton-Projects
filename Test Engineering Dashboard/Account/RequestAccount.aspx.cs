using System;
using System.IO;
using System.Net.Mail;
using System.Text;
using System.Web.UI;
using System.Configuration;
using System.Data.SqlClient;

public partial class TED_Account_RequestAccount : Page
{
    private string _constr;
    protected void Page_Load(object sender, EventArgs e)
    {
        if (_constr == null)
        {
            _constr = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        }
        if (!IsPostBack)
        {
            BindDropDowns();
        }
    }

    private void BindDropDowns()
    {
        ddlDepartment.Items.Clear();
        ddlDepartment.Items.Add("-- Select --");
        
        ddlJobRole.Items.Clear();
        ddlJobRole.Items.Add("-- Select --");
        
        using (var conn = new SqlConnection(_constr))
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
        }
    }

    protected void btnSubmit_Click(object sender, EventArgs e)
    {
        lblStatus.CssClass = "status"; // reset
        var fullName = txtFullName.Text.Trim();
        var eNumber = txtENumber.Text.Trim();
        var email = txtEmail.Text.Trim();
        var dept = ddlDepartment.SelectedValue;
        var role = ddlJobRole.SelectedValue;
        var pw1 = txtPassword.Text;
        var pw2 = txtPassword2.Text;

        // Determine if email is required based on E Number
        var eNumberUpper = eNumber.ToUpper();
        var isContractor = eNumberUpper.StartsWith("C");
        var emailRequired = !isContractor; // Email not required for C numbers

        // Basic validation
        if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(eNumber) || dept.StartsWith("--") || role.StartsWith("--") || string.IsNullOrEmpty(pw1) || string.IsNullOrEmpty(pw2))
        {
            Fail("Please complete all required fields.");
            return;
        }
        
        // Email validation - only required if not a contractor
        if (emailRequired && string.IsNullOrEmpty(email))
        {
            Fail("Email is required for E numbers.");
            return;
        }
        
        if (!string.IsNullOrEmpty(email) && !email.Contains("@"))
        {
            Fail("Email format appears invalid.");
            return;
        }
        
        if (!eNumber.StartsWith("E", StringComparison.OrdinalIgnoreCase) && !eNumber.StartsWith("C", StringComparison.OrdinalIgnoreCase))
        {
            Fail("E Number should start with 'E' or 'C'.");
            return;
        }
        if (pw1.Length < 8)
        {
            Fail("Password must be at least 8 characters.");
            return;
        }
        if (pw1 != pw2)
        {
            Fail("Passwords do not match.");
            return;
        }

        // Store password as plain text (will be used when admin approves)
        var password = pw1;

        string pictureInfo = "(none)";
        string savedProfileRelPath = null; // app-relative like "Uploads/ProfilePictures/abc.png"
        string savedProfilePhysicalPath = null;
        string profileContentType = null;
        if (fuProfile.HasFile)
        {
            try
            {
                // Validate
                var ext = Path.GetExtension(fuProfile.FileName);
                ext = ext == null ? string.Empty : ext.ToLowerInvariant();
                if (ext != ".png" && ext != ".jpg" && ext != ".jpeg")
                {
                    Fail("Profile picture must be PNG or JPG.");
                    return;
                }
                if (fuProfile.PostedFile.ContentLength > 2 * 1024 * 1024)
                {
                    Fail("Profile picture exceeds 2 MB limit.");
                    return;
                }

                // Build a safe, unique filename: ENumber_yyyyMMddHHmmssfff.ext (fallback to 'profile' if ENumber invalid)
                string baseName = string.IsNullOrEmpty(eNumber) ? "profile" : eNumber;
                var sbn = new StringBuilder(baseName.Length);
                for (int i = 0; i < baseName.Length; i++)
                {
                    char c = baseName[i];
                    if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-') sbn.Append(c);
                }
                baseName = sbn.Length > 0 ? sbn.ToString() : "profile";
                string stamp = DateTime.UtcNow.ToString("yyyyMMddHHmmssfff");
                string finalFileName = baseName + "_" + stamp + ext;

                // Ensure upload folder and save
                // Resolve folder from appSettings
                var uploadsRoot = ConfigurationManager.AppSettings["TED.UploadsRoot"] ?? "~/Uploads";
                var picturesSub = ConfigurationManager.AppSettings["TED.ProfilePicturesSubfolder"] ?? "ProfilePictures";
                string relFolder = uploadsRoot.TrimEnd('/', '\\') + "/" + picturesSub.TrimStart('/', '\\');
                if (!relFolder.StartsWith("~/")) relFolder = "~/" + relFolder.TrimStart('/', '\\');
                string physFolder = Server.MapPath(relFolder);
                if (!Directory.Exists(physFolder)) Directory.CreateDirectory(physFolder);
                savedProfilePhysicalPath = Path.Combine(physFolder, finalFileName);
                fuProfile.SaveAs(savedProfilePhysicalPath);
                // Build app-relative (without leading '~') for storage
                string relPrefix = relFolder.StartsWith("~/") ? relFolder.Substring(2) : relFolder.TrimStart('/', '\\');
                savedProfileRelPath = relPrefix.TrimEnd('/', '\\') + "/" + finalFileName;
                profileContentType = fuProfile.PostedFile.ContentType;

                pictureInfo = finalFileName + " (" + (fuProfile.PostedFile.ContentLength / 1024) + " KB)";
            }
            catch (Exception ex)
            {
                Fail("Error saving profile picture: " + ex.Message);
                return;
            }
        }

        var sb = new StringBuilder();
        sb.AppendLine("A new Test Engineering Dashboard account request was submitted:");
        sb.AppendLine();
        sb.AppendLine("Full Name: " + fullName);
        sb.AppendLine("E Number: " + eNumber);
        sb.AppendLine("Email: " + email);
        sb.AppendLine("Department: " + dept);
        sb.AppendLine("Job Role: " + role);
    sb.AppendLine("Profile Picture: " + pictureInfo);
    if (!string.IsNullOrEmpty(savedProfileRelPath)) sb.AppendLine("Profile Path: " + savedProfileRelPath);
        sb.AppendLine();
        sb.AppendLine("(Password not included for security)");
        sb.AppendLine("Submitted: " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));

        // Save request to database (with optional profile image bytes)
        int newRequestId;
        try
        {
            using (var conn = new SqlConnection(_constr))
            using (var cmd = new SqlCommand(@"INSERT INTO dbo.AccountRequests
                    (SubmittedAt, Status, FullName, ENumber, Email, Department, JobRole, PasswordHash, ProfileFileName, ProfileContentType, ClientIp, UserAgent, ProfilePath)
                OUTPUT INSERTED.RequestID
                VALUES (SYSUTCDATETIME(), N'Pending', @FullName, @ENumber, @Email, @Department, @JobRole, @PasswordHash, @ProfileFileName, @ProfileContentType, @ClientIp, @UserAgent, @ProfilePath);", conn))
            {
                cmd.Parameters.AddWithValue("@FullName", fullName);
                cmd.Parameters.AddWithValue("@ENumber", eNumber);
                cmd.Parameters.AddWithValue("@Email", string.IsNullOrEmpty(email) ? (object)DBNull.Value : email);
                cmd.Parameters.AddWithValue("@Department", dept);
                cmd.Parameters.AddWithValue("@JobRole", role);
                cmd.Parameters.AddWithValue("@PasswordHash", password);
                if (!string.IsNullOrEmpty(savedProfileRelPath))
                {
                    cmd.Parameters.AddWithValue("@ProfileFileName", Path.GetFileName(savedProfileRelPath));
                    cmd.Parameters.AddWithValue("@ProfileContentType", (object)(profileContentType ?? (string)null) ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@ProfilePath", savedProfileRelPath);
                }
                else
                {
                    cmd.Parameters.AddWithValue("@ProfileFileName", (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@ProfileContentType", (object)DBNull.Value);
                    cmd.Parameters.AddWithValue("@ProfilePath", (object)DBNull.Value);
                }
                // Client diagnostics
                var ip = Request.UserHostAddress;
                var ua = Request.UserAgent;
                cmd.Parameters.AddWithValue("@ClientIp", (object)(ip ?? (string)null) ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@UserAgent", (object)(ua ?? (string)null) ?? DBNull.Value);

                conn.Open();
                newRequestId = (int)cmd.ExecuteScalar();
            }
        }
        catch (Exception ex)
        {
            Fail("Failed to save request: " + ex.Message);
            return;
        }

        // Email notification remains (no plaintext password)
        try
        {
            var toAddress = "JonatanDArias@Eaton.com"; // destination
            var msg = new MailMessage();
            msg.To.Add(toAddress);
            msg.Subject = "[TED] Account Request (#" + newRequestId + "): " + fullName + " (" + eNumber + ")";
            msg.Body = sb.ToString();
            msg.IsBodyHtml = false;

            if (!string.IsNullOrEmpty(savedProfilePhysicalPath) && File.Exists(savedProfilePhysicalPath))
            {
                msg.Attachments.Add(new Attachment(savedProfilePhysicalPath));
            }

            using (var client = new SmtpClient())
            {
                client.Send(msg);
            }

            lblStatus.Text = "Request submitted successfully. You will be contacted once reviewed.";
            lblStatus.CssClass = "status success";
            ClearForm();
        }
        catch (Exception ex)
        {
            Fail("Saved request but failed to send email: " + ex.Message);
        }
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ClearForm();
        lblStatus.Text = "Form cleared.";
        lblStatus.CssClass = "status";
    }

    private void ClearForm()
    {
        txtFullName.Text = string.Empty;
        txtENumber.Text = string.Empty;
        txtEmail.Text = string.Empty;
        ddlDepartment.SelectedIndex = 0;
        ddlJobRole.SelectedIndex = 0;
        txtPassword.Text = string.Empty;
        txtPassword2.Text = string.Empty;
    }

    private void Fail(string message)
    {
        lblStatus.Text = message;
        lblStatus.CssClass = "status error";
    }

    private static string ComputeSha256(string input)
    {
        using (var sha = System.Security.Cryptography.SHA256.Create())
        {
            var bytes = Encoding.UTF8.GetBytes(input);
            var hash = sha.ComputeHash(bytes);
            return BitConverter.ToString(hash).Replace("-", string.Empty).ToLowerInvariant();
        }
    }
}