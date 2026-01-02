using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class TED_Admin_Requests : Page
{
    protected override void OnPreRender(EventArgs e)
    {
        base.OnPreRender(e);
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Pending Requests", null);
        }
    }
    protected void Page_Load(object sender, EventArgs e)
    {
        // Require admin role
        var cat = (Session["TED:UserCategory"] as string ?? string.Empty).ToLowerInvariant();
        var role = (Session["TED:JobRole"] as string ?? string.Empty).ToLowerInvariant();
        if (!(cat.Contains("admin") || role.Contains("admin")))
        {
            Response.Redirect("~/UnauthorizedAccess.aspx");
            return;
        }

        // Set page title in header
        var header = FindControl("AdminHeader1");
        if (header != null)
        {
            var prop = header.GetType().GetProperty("Title");
            if (prop != null) prop.SetValue(header, "Pending Requests", null);
        }
        var sidebar = FindControl("AdminSidebar1");
        if (sidebar != null)
        {
            var prop = sidebar.GetType().GetProperty("Active");
            if (prop != null) prop.SetValue(sidebar, "requests", null);
        }

        // Register production lines data for JavaScript
        RegisterProductionLinesScript();

        if (!IsPostBack)
        {
            BindRequests();
        }
    }

    protected void gridRequests_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        int reqId;
        if (!int.TryParse(e.CommandArgument as string, out reqId)) return;

        if (e.CommandName == "Approve")
        {
            GridViewRow row = ((Control)e.CommandSource).NamingContainer as GridViewRow;
            if (row != null)
            {
                var ddlRole = row.FindControl("ddlAssignRole") as DropDownList;
                var ddlDept = row.FindControl("ddlDepartment") as DropDownList;
                var ddlJobRole = row.FindControl("ddlJobRole") as DropDownList;
                var hiddenTestLine = Request.Form["hiddenTestLine_" + reqId];
                
                var selectedUserCategory = ddlRole != null ? ddlRole.SelectedValue : null;
                var selectedDepartment = ddlDept != null ? ddlDept.SelectedValue : null;
                var selectedJobRole = ddlJobRole != null ? ddlJobRole.SelectedValue : null;
                var selectedTestLines = hiddenTestLine ?? string.Empty;

                var req = GetRequestById(reqId);
                if (req != null)
                {
                    // Log admin: request approved
                    TryLogAdminAction("dbo.AccountRequests", req.RequestID.ToString(), req.FullName, "Request Approved", string.Empty, "Approved", "Modified");
                    // Create or update a user record directly upon approval
                    bool created = false; int newUserId = 0;
                    try
                    {
                        CreateOrUpdateUserFromRequest(req, selectedUserCategory, selectedDepartment, selectedJobRole, selectedTestLines, out created, out newUserId);
                    }
                    catch { }
                }
                UpdateRequestStatus(reqId, "Approved");
                if (req != null)
                {
                    TryEmail(req.Email, "Your account request was approved", "Hello, your request has been approved and is being provisioned.");
                }
                // Feedback toast and refresh grid, no redirect
                try
                {
                    var sm = ScriptManager.GetCurrent(this.Page);
                    var msg = "Request approved and user provisioned.";
                    if (sm != null) ScriptManager.RegisterStartupScript(this, this.GetType(), "toastApprove", "window.showToast('" + msg.Replace("'", "\\'") + "','success');", true);
                    else ClientScript.RegisterStartupScript(this.GetType(), "toastApprove", "window.showToast('" + msg.Replace("'", "\\'") + "','success');", true);
                }
                catch { }
                BindRequests();
                return;
            }
        }
        else if (e.CommandName == "Reject")
        {
            var req = GetRequestById(reqId);
            if (req != null)
            {
                // Log admin: request rejected
                TryLogAdminAction("dbo.AccountRequests", req.RequestID.ToString(), req.FullName, "Request Rejected", string.Empty, "Rejected", "Modified");
            }
            UpdateRequestStatus(reqId, "Rejected");
            if (req != null)
            {
                TryEmail(req.Email, "Your account request was rejected", "Hello, your request was reviewed and rejected. Please contact an administrator for details.");
            }
            try
            {
                var sm = ScriptManager.GetCurrent(this.Page);
                var msg = "Request rejected.";
                if (sm != null) ScriptManager.RegisterStartupScript(this, this.GetType(), "toastReject", "window.showToast('" + msg.Replace("'", "\\'") + "','error');", true);
                else ClientScript.RegisterStartupScript(this.GetType(), "toastReject", "window.showToast('" + msg.Replace("'", "\\'") + "','error');", true);
            }
            catch { }
        }
        BindRequests();
    }

    protected void gridRequests_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            var data = e.Row.DataItem as dynamic;
            // Render status badge
            var statusLit = e.Row.FindControl("litStatus") as Literal;
            if (statusLit != null && data != null)
            {
                var st = (data.Status as string ?? "").Trim();
                var cls = "badge";
                var stLower = st.ToLowerInvariant();
                if (stLower.Contains("pending")) cls += " badge-pending";
                else if (stLower.Contains("approved")) cls += " badge-approved";
                else if (stLower.Contains("rejected")) cls += " badge-rejected";
                statusLit.Text = "<span class='" + cls + "'>" + (string.IsNullOrWhiteSpace(st) ? "-" : st) + "</span>";
            }
            // Preselect dropdowns based on request data
            var ddlAssignRole = e.Row.FindControl("ddlAssignRole") as DropDownList;
            var ddlDepartment = e.Row.FindControl("ddlDepartment") as DropDownList;
            var ddlJobRole = e.Row.FindControl("ddlJobRole") as DropDownList;
            
            if (data != null)
            {
                // Preselect department
                if (ddlDepartment != null)
                {
                    var dept = data.Department as string;
                    var deptItem = ddlDepartment.Items.FindByText(dept);
                    if (deptItem != null) ddlDepartment.SelectedValue = deptItem.Value;
                }
                
                // Preselect job role
                if (ddlJobRole != null)
                {
                    var jr = data.JobRole as string;
                    var jrItem = ddlJobRole.Items.FindByText(jr);
                    if (jrItem != null) ddlJobRole.SelectedValue = jrItem.Value;
                }
                
                // Preselect user category (default to job role mapping)
                if (ddlAssignRole != null)
                {
                    var jr = data.JobRole as string ?? "";
                    var item = ddlAssignRole.Items.FindByText(jr);
                    if (item != null) 
                        ddlAssignRole.SelectedValue = item.Value;
                    else
                    {
                        // Default mappings
                        if (jr.Contains("Engineer")) ddlAssignRole.SelectedValue = "Test Engineering";
                        else if (jr.Contains("Manager") || jr.Contains("Supervisor")) ddlAssignRole.SelectedValue = "Admin";
                        else if (jr.Contains("Tester") || jr.Contains("Technician")) ddlAssignRole.SelectedValue = "Tester";
                        else if (jr.Contains("Analyst")) ddlAssignRole.SelectedValue = "Quality";
                        else ddlAssignRole.SelectedValue = "Viewer";
                    }
                }
            }

            // Disable actions and dropdowns when not pending
            var statusStr = data != null ? (data.Status as string ?? string.Empty) : string.Empty;
            bool isPending = statusStr.Trim().Equals("Pending", StringComparison.OrdinalIgnoreCase);
            var btnApprove = e.Row.FindControl("btnApprove") as LinkButton;
            var btnReject = e.Row.FindControl("btnReject") as LinkButton;
            if (!isPending)
            {
                if (ddlAssignRole != null) ddlAssignRole.Enabled = false;
                if (ddlDepartment != null) ddlDepartment.Enabled = false;
                if (ddlJobRole != null) ddlJobRole.Enabled = false;
                if (btnApprove != null) { btnApprove.Enabled = false; btnApprove.CssClass = (btnApprove.CssClass + " disabled").Trim(); }
                if (btnReject != null) { btnReject.Enabled = false; btnReject.CssClass = (btnReject.CssClass + " disabled").Trim(); }
            }

            // Avatar fallback to initials when image is missing
            var img = e.Row.FindControl("imgAvatar") as Image;
            var pnl = e.Row.FindControl("pnlInitials") as Panel;
            var lit = e.Row.FindControl("litInitials") as Literal;
            if (img != null && pnl != null && lit != null)
            {
                var name = data != null ? (data.FullName as string ?? string.Empty) : string.Empty;
                // Always set initials text so fallback is ready
                lit.Text = GetInitials(name);

                bool showFallback = true;
                try
                {
                    var url = img.ImageUrl;
                    if (!string.IsNullOrWhiteSpace(url))
                    {
                        // If url is app-relative or relative, MapPath works; if not, keep fallback
                        var urlToMap = HttpUtility.UrlDecode(url);
                        var abs = Server.MapPath(urlToMap);
                        if (File.Exists(abs)) showFallback = false;
                    }
                }
                catch { showFallback = true; }

                // Wire client-side handlers to ensure runtime fallback
                try
                {
                    img.Attributes["onerror"] = "this.style.display='none'; if(this.nextElementSibling){ this.nextElementSibling.style.display='flex'; }";
                    img.Attributes["onload"] = "if(this.naturalWidth>0 && this.naturalHeight>0){ this.style.display='block'; if(this.nextElementSibling){ this.nextElementSibling.style.display='none'; } }";
                }
                catch { }

                // Always render both controls; control initial state via styles so JS can swap if needed
                img.Visible = true;
                pnl.Visible = true;
                try
                {
                    var imgStyle = (img.Attributes["style"] ?? string.Empty);
                    var pnlStyle = (pnl.Attributes["style"] ?? string.Empty);
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
                    img.Attributes["style"] = imgStyle;
                    pnl.Attributes["style"] = pnlStyle;
                }
                catch { }
            }
        }
        else if (e.Row.RowType == DataControlRowType.Header)
        {
            // Apply sorted class to header cell for chevrons
            var sortExpr = (ViewState["SortExpr"] as string) ?? "SubmittedAt";
            var sortDir = (ViewState["SortDir"] as string) ?? "DESC";
            int colIndex = GetSortedColumnIndex(sortExpr);
            if (colIndex >= 0 && colIndex < e.Row.Cells.Count)
            {
                var cls = sortDir.Equals("DESC", StringComparison.OrdinalIgnoreCase) ? "sorted-desc" : "sorted-asc";
                var existing = e.Row.Cells[colIndex].CssClass ?? string.Empty;
                e.Row.Cells[colIndex].CssClass = (existing + " " + cls).Trim();
            }
        }
    }

    protected void gridRequests_Sorting(object sender, GridViewSortEventArgs e)
    {
        string currentExpr = (ViewState["SortExpr"] as string) ?? "SubmittedAt";
        string currentDir = (ViewState["SortDir"] as string) ?? "DESC";
        string newExpr = e.SortExpression;
        if (string.Equals(currentExpr, newExpr, StringComparison.OrdinalIgnoreCase))
        {
            // Toggle
            currentDir = currentDir.Equals("ASC", StringComparison.OrdinalIgnoreCase) ? "DESC" : "ASC";
        }
        else
        {
            currentExpr = newExpr;
            currentDir = "ASC";
        }
        ViewState["SortExpr"] = currentExpr;
        ViewState["SortDir"] = currentDir;
        BindRequests();
    }

    protected void gridRequests_RowCreated(object sender, GridViewRowEventArgs e)
    {
        // Re-apply header class after creation as well
        if (e.Row.RowType == DataControlRowType.Header)
        {
            var sortExpr = (ViewState["SortExpr"] as string) ?? "SubmittedAt";
            var sortDir = (ViewState["SortDir"] as string) ?? "DESC";
            int colIndex = GetSortedColumnIndex(sortExpr);
            if (colIndex >= 0 && colIndex < e.Row.Cells.Count)
            {
                var cls = sortDir.Equals("DESC", StringComparison.OrdinalIgnoreCase) ? "sorted-desc" : "sorted-asc";
                e.Row.Cells[colIndex].CssClass = ((e.Row.Cells[colIndex].CssClass ?? string.Empty) + " " + cls).Trim();
            }
        }
    }

    private string GetInitials(string name)
    {
        if (string.IsNullOrWhiteSpace(name)) return "?";
        var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        if (parts.Length == 1)
        {
            return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
        }
        return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpperInvariant();
    }

    protected void txtSearch_TextChanged(object sender, EventArgs e)
    {
        ViewState["PageIndex"] = 0;
        BindRequests();
    }

    protected void ddlStatus_SelectedIndexChanged(object sender, EventArgs e)
    {
        ViewState["PageIndex"] = 0;
        BindRequests();
    }

    protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
    {
        ViewState["PageIndex"] = 0;
        BindRequests();
    }

    protected void btnPrev_Click(object sender, EventArgs e)
    {
        int i = (int)(ViewState["PageIndex"] ?? 0);
        if (i > 0) i--;
        ViewState["PageIndex"] = i;
        BindRequests();
    }

    protected void btnNext_Click(object sender, EventArgs e)
    {
        int i = (int)(ViewState["PageIndex"] ?? 0);
        i++;
        ViewState["PageIndex"] = i;
        BindRequests();
    }

    private void BindRequests()
    {
        var list = new List<dynamic>();
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand())
            {
                cmd.Connection = conn;
                var pageSize = Math.Max(1, ParseInt(ddlPageSize.SelectedValue, 10));
                var pageIndex = Math.Max(0, (int)(ViewState["PageIndex"] ?? 0));
                var status = (ddlStatus.SelectedValue ?? "Pending");
                var search = (txtSearch.Text ?? string.Empty).Trim();
                var where = "WHERE 1=1";
                if (!string.Equals(status, "All", StringComparison.OrdinalIgnoreCase))
                {
                    where += " AND Status = @s";
                    cmd.Parameters.AddWithValue("@s", status);
                }
                if (!string.IsNullOrEmpty(search))
                {
                    where += " AND (FullName LIKE @q OR ENumber LIKE @q OR Email LIKE @q OR Department LIKE @q OR JobRole LIKE @q)";
                    cmd.Parameters.AddWithValue("@q", "%" + search + "%");
                }

                // Sorting
                string sortExpr = (ViewState["SortExpr"] as string) ?? "SubmittedAt";
                string sortDir = (ViewState["SortDir"] as string) ?? "DESC";
                var allowed = new System.Collections.Generic.HashSet<string>(StringComparer.OrdinalIgnoreCase)
                { "FullName","Department","JobRole","SubmittedAt","Email","ENumber","Status" };
                if (!allowed.Contains(sortExpr)) sortExpr = "SubmittedAt";
                sortDir = sortDir.Equals("ASC", StringComparison.OrdinalIgnoreCase) ? "ASC" : "DESC";

                cmd.CommandText = "SELECT RequestID, SubmittedAt, Status, FullName, ENumber, Email, Department, JobRole, ProfilePath " +
                                  "FROM dbo.AccountRequests " + where + " " +
                                  "ORDER BY " + sortExpr + " " + sortDir + " " +
                                  "OFFSET (@skip) ROWS FETCH NEXT (@take) ROWS ONLY; " +
                                  "SELECT COUNT(1) FROM dbo.AccountRequests " + where + ";";
                cmd.Parameters.AddWithValue("@skip", pageIndex * pageSize);
                cmd.Parameters.AddWithValue("@take", pageSize);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var rel = rdr["ProfilePath"] as string;
                        var en = rdr["ENumber"].ToString();
                        var thumb = ResolveThumbUrlOrFind(rel, en);
                        list.Add(new
                        {
                            RequestID = (int)rdr["RequestID"],
                            SubmittedAt = rdr["SubmittedAt"],
                            Status = rdr["Status"].ToString(),
                            FullName = rdr["FullName"].ToString(),
                            ENumber = rdr["ENumber"].ToString(),
                            Email = rdr["Email"].ToString(),
                            Department = rdr["Department"].ToString(),
                            JobRole = rdr["JobRole"].ToString(),
                            ProfileThumbUrl = thumb
                        });
                    }
                    int total = 0;
                    if (rdr.NextResult() && rdr.Read()) total = Convert.ToInt32(rdr[0]);
                    lblTotal.Text = "Total: " + total.ToString();
                    lblPage.Text = "Page " + (pageIndex + 1).ToString();
                    btnPrev.Enabled = pageIndex > 0;
                    btnNext.Enabled = (pageIndex + 1) * pageSize < total;
                }
            }
        }
        catch { }
        gridRequests.DataSource = list;
        gridRequests.DataBind();
    }

    private int GetSortedColumnIndex(string sortExpr)
    {
        // Map SortExpression to column index by scanning fields
        int index = 0;
        foreach (DataControlField field in gridRequests.Columns)
        {
            var expr = field.SortExpression;
            if (!string.IsNullOrEmpty(expr) && string.Equals(expr, sortExpr, StringComparison.OrdinalIgnoreCase))
            {
                return index;
            }
            index++;
        }
        return -1;
    }

    private string ResolveThumbUrl(string rel)
    {
        if (string.IsNullOrWhiteSpace(rel)) return ResolveDefaultAvatar();
        try
        {
            var abs = Server.MapPath(rel);
            if (File.Exists(abs)) return HttpUtility.UrlPathEncode(ResolveUrl(rel));
            return ResolveDefaultAvatar();
        }
        catch { return ResolveDefaultAvatar(); }
    }

    private string ResolveThumbUrlOrFind(string rel, string eNumber)
    {
        // If explicit relative path is present and exists, use it
        if (!string.IsNullOrWhiteSpace(rel))
        {
            try
            {
                var abs = Server.MapPath(rel);
                if (File.Exists(abs)) return HttpUtility.UrlPathEncode(ResolveUrl(rel));
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
                // Fast path: exact file name match ENumber.*
                foreach (var ext in exts)
                {
                    var candidate = Path.Combine(absFolder, en + ext);
                    try { if (File.Exists(candidate)) return HttpUtility.UrlPathEncode(ResolveUrl(virtFolder + en + ext)); } catch { }
                }
                // Prefix match: ENumber_* or ENumber-*
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
                    if (!string.IsNullOrEmpty(best)) return HttpUtility.UrlPathEncode(ResolveUrl(virtFolder + Path.GetFileName(best)));
                }
                catch { }
            }
        }
        catch { }
        // No image found; returning null allows initials fallback to remain visible
        return null;
    }

    private string ResolveDefaultAvatar()
    {
        try
        {
            var png = Server.MapPath("~/Images/Users/default-avatar.png");
            if (File.Exists(png)) return HttpUtility.UrlPathEncode(ResolveUrl("~/Images/Users/default-avatar.png"));
        }
        catch { }
        return HttpUtility.UrlPathEncode(ResolveUrl("~/Images/Users/default-avatar.svg"));
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

    private void UpdateRequestStatus(int requestId, string status)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"UPDATE dbo.AccountRequests
                                              SET Status = @s, ReviewedAt = SYSUTCDATETIME(), ReviewedBy = @by, Decision = @s
                                              WHERE RequestID = @id", conn))
            {
                cmd.Parameters.AddWithValue("@s", status);
                var by = (Session["TED:FullName"] as string) ?? User.Identity.Name ?? "Admin";
                cmd.Parameters.AddWithValue("@by", by);
                cmd.Parameters.AddWithValue("@id", requestId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }
        catch { }
    }

    private dynamic GetRequestById(int id)
    {
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            using (var cmd = new SqlCommand(@"SELECT TOP 1 RequestID, SubmittedAt, FullName, ENumber, Email, Department, JobRole, ProfilePath, PasswordHash
                                              FROM dbo.AccountRequests WHERE RequestID=@id", conn))
            {
                cmd.Parameters.AddWithValue("@id", id);
                conn.Open();
                using (var rdr = cmd.ExecuteReader())
                {
                    if (rdr.Read())
                    {
                        var pwd = rdr["PasswordHash"] as string;
                        return new
                        {
                            RequestID = (int)rdr["RequestID"],
                            SubmittedAt = rdr["SubmittedAt"],
                            FullName = rdr["FullName"].ToString(),
                            ENumber = rdr["ENumber"].ToString(),
                            Email = rdr["Email"].ToString(),
                            Department = rdr["Department"].ToString(),
                            JobRole = rdr["JobRole"].ToString(),
                            ProfilePath = rdr["ProfilePath"] as string,
                            Password = pwd != null ? pwd.Trim() : null
                        };
                    }
                }
            }
        }
        catch { }
        return null;
    }

    private void TryEmail(string to, string subject, string body)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(to)) return;
            var msg = new System.Net.Mail.MailMessage();
            msg.To.Add(to);
            msg.Subject = subject;
            msg.Body = body;
            var smtp = new System.Net.Mail.SmtpClient();
            smtp.Send(msg);
        }
        catch { }
    }

    private void CreateOrUpdateUserFromRequest(dynamic req, string assignedCategory, string overrideDepartment, string overrideJobRole, string testLines, out bool createdNew, out int userId)
    {
        createdNew = false; userId = 0;
        try
        {
            var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                // Discover existing columns for robustness
                var available = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                using (var check = new SqlCommand("SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='Users'", conn))
                using (var rdr = check.ExecuteReader())
                { while (rdr.Read()) available.Add(rdr.GetString(0)); }

                // Determine allowed categories by parsing the CHECK constraint, if present
                var allowed = GetAllowedUserCategories(conn);

                // Determine if a user already exists by ENumber or Email
                int existingId = 0;
                using (var find = new SqlCommand("SELECT TOP 1 UserID FROM dbo.Users WHERE ENumber=@en OR Email=@em", conn))
                {
                    find.Parameters.AddWithValue("@en", (object)(req.ENumber ?? string.Empty));
                    find.Parameters.AddWithValue("@em", (object)(req.Email ?? string.Empty));
                    var o = find.ExecuteScalar();
                    if (o != null && o != DBNull.Value) existingId = Convert.ToInt32(o);
                }

                var desiredCategory = !string.IsNullOrWhiteSpace(assignedCategory) ? assignedCategory : (req.JobRole as string ?? "Viewer");
                var category = NormalizeCategoryToAllowed(desiredCategory, allowed);
                var createdBy = (Session["TED:FullName"] as string) ?? User.Identity.Name ?? "Admin";
                var modifiedBy = (Session["TED:ENumber"] as string) ?? createdBy;

                if (existingId > 0)
                {
                    // Update existing user with latest info from request; keep existing password as-is
                    var setList = new List<string>();
                    var cmd = new SqlCommand();
                    cmd.Connection = conn;
                    Action<string, string, object> add = (col, param, val) => { setList.Add(col + "=" + param); cmd.Parameters.AddWithValue(param, val ?? (object)string.Empty); };

                    add("FullName", "@n", req.FullName);
                    if (available.Contains("Department")) add("Department", "@d", !string.IsNullOrWhiteSpace(overrideDepartment) ? overrideDepartment : req.Department);
                    add("JobRole", "@r", !string.IsNullOrWhiteSpace(overrideJobRole) ? overrideJobRole : req.JobRole);
                    add("UserCategory", "@c", category);
                    add("IsActive", "@a", true);
                    if (available.Contains("TestLine")) add("TestLine", "@tl", testLines ?? string.Empty);
                    if (available.Contains("ModifiedDate")) { setList.Add("ModifiedDate=GETDATE()"); }
                    if (available.Contains("ModifiedBy")) { add("ModifiedBy", "@mb", modifiedBy); }
                    if (available.Contains("ProfilePath") && !string.IsNullOrWhiteSpace(req.ProfilePath as string)) add("ProfilePath", "@pp", req.ProfilePath);

                    cmd.CommandText = "UPDATE dbo.Users SET " + string.Join(", ", setList) + " WHERE UserID=@id";
                    cmd.Parameters.AddWithValue("@id", existingId);
                    cmd.ExecuteNonQuery();
                    createdNew = false; userId = existingId; return;
                }
                else
                {
                    // Insert new user; use password from request or default to "Temp123!"
                    var cols = new List<string>(); var vals = new List<string>(); var cmd = new SqlCommand(); cmd.Connection = conn;
                    cols.Add("FullName"); vals.Add("@n"); cmd.Parameters.AddWithValue("@n", (object)(req.FullName ?? string.Empty));
                    cols.Add("ENumber"); vals.Add("@en"); cmd.Parameters.AddWithValue("@en", (object)(req.ENumber ?? string.Empty));
                    cols.Add("Email"); vals.Add("@em"); cmd.Parameters.AddWithValue("@em", (object)(req.Email ?? string.Empty));
                    cols.Add("Password"); vals.Add("@p"); 
                    var password = !string.IsNullOrWhiteSpace(req.Password as string) ? (string)req.Password : "Temp123!";
                    cmd.Parameters.AddWithValue("@p", password);
                    if (available.Contains("Department")) { cols.Add("Department"); vals.Add("@d"); cmd.Parameters.AddWithValue("@d", (object)(!string.IsNullOrWhiteSpace(overrideDepartment) ? overrideDepartment : (req.Department ?? string.Empty))); }
                    cols.Add("JobRole"); vals.Add("@r"); cmd.Parameters.AddWithValue("@r", (object)(!string.IsNullOrWhiteSpace(overrideJobRole) ? overrideJobRole : (req.JobRole ?? string.Empty)));
                    cols.Add("UserCategory"); vals.Add("@c"); cmd.Parameters.AddWithValue("@c", (object)category);
                    cols.Add("IsActive"); vals.Add("@a"); cmd.Parameters.AddWithValue("@a", true);
                    if (available.Contains("TestLine")) { cols.Add("TestLine"); vals.Add("@tl"); cmd.Parameters.AddWithValue("@tl", (object)(testLines ?? string.Empty)); }
                    if (available.Contains("CreatedDate")) { cols.Add("CreatedDate"); vals.Add("GETDATE()"); }
                    if (available.Contains("CreatedBy")) { cols.Add("CreatedBy"); vals.Add("@cb"); cmd.Parameters.AddWithValue("@cb", createdBy); }
                    if (available.Contains("ProfilePath") && !string.IsNullOrWhiteSpace(req.ProfilePath as string)) { cols.Add("ProfilePath"); vals.Add("@pp"); cmd.Parameters.AddWithValue("@pp", req.ProfilePath); }

                    cmd.CommandText = "INSERT INTO dbo.Users(" + string.Join(",", cols) + ") OUTPUT INSERTED.UserID VALUES(" + string.Join(",", vals) + ")";
                    var o = cmd.ExecuteScalar();
                    userId = o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
                    createdNew = true; return;
                }
            }
        }
        catch { createdNew = false; userId = 0; }
    }

    private HashSet<string> GetAllowedUserCategories(SqlConnection conn)
    {
        var list = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        try
        {
            using (var cmd = new SqlCommand(@"SELECT TOP 1 cc.definition
                                              FROM sys.check_constraints cc
                                              INNER JOIN sys.tables t ON cc.parent_object_id = t.object_id
                                              WHERE t.name='Users' AND cc.definition LIKE '%UserCategory%'", conn))
            {
                var def = cmd.ExecuteScalar() as string;
                if (!string.IsNullOrWhiteSpace(def))
                {
                    var idx = def.IndexOf(" IN ", StringComparison.OrdinalIgnoreCase);
                    if (idx >= 0)
                    {
                        var open = def.IndexOf('(', idx);
                        var close = def.IndexOf(')', open + 1);
                        if (open > 0 && close > open)
                        {
                            var inside = def.Substring(open + 1, close - open - 1);
                            foreach (var part in inside.Split(','))
                            {
                                var s = part.Trim().Trim('"', '\'', ' ', '[', ']');
                                if (!string.IsNullOrEmpty(s)) list.Add(s);
                            }
                        }
                    }
                }
            }
        }
        catch { }
        return list;
    }

    private string NormalizeCategoryToAllowed(string ui, HashSet<string> allowed)
    {
        if (string.IsNullOrWhiteSpace(ui)) ui = "Viewer";
        if (allowed != null && allowed.Count > 0)
        {
            // Direct match
            var hit = allowed.FirstOrDefault(x => x.Equals(ui, StringComparison.OrdinalIgnoreCase));
            if (!string.IsNullOrEmpty(hit)) return hit;
            // Heuristics
            if (ui.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase) || ui.Equals("Engineer", StringComparison.OrdinalIgnoreCase))
            {
                var te = allowed.FirstOrDefault(x => x.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(te)) return te;
                var user = allowed.FirstOrDefault(x => x.Equals("User", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(user)) return user;
            }
            if (ui.Equals("Tester", StringComparison.OrdinalIgnoreCase) || ui.Equals("Technician", StringComparison.OrdinalIgnoreCase) || ui.Equals("Operator", StringComparison.OrdinalIgnoreCase))
            {
                var tester = allowed.FirstOrDefault(x => x.Equals("Tester", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(tester)) return tester;
                var to = allowed.FirstOrDefault(x => x.Equals("Test Operator", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(to)) return to;
                var user = allowed.FirstOrDefault(x => x.Equals("User", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(user)) return user;
            }
            if (ui.Equals("Quality", StringComparison.OrdinalIgnoreCase))
            {
                var q = allowed.FirstOrDefault(x => x.Equals("Quality", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(q)) return q;
                var user = allowed.FirstOrDefault(x => x.Equals("User", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(user)) return user;
            }
            if (ui.Equals("Viewer", StringComparison.OrdinalIgnoreCase))
            {
                var viewer = allowed.FirstOrDefault(x => x.Equals("Viewer", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(viewer)) return viewer;
            }
            if (ui.Equals("Admin", StringComparison.OrdinalIgnoreCase))
            {
                var admin = allowed.FirstOrDefault(x => x.Equals("Admin", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(admin)) return admin;
            }
            // Fallbacks
            var anyUser = allowed.FirstOrDefault(x => x.Equals("User", StringComparison.OrdinalIgnoreCase)); if (!string.IsNullOrEmpty(anyUser)) return anyUser;
            return allowed.FirstOrDefault() ?? "User";
        }
        // No constraint info; preserve standard categories
        var v = (ui ?? "").Trim();
        if (v.Equals("Admin", StringComparison.OrdinalIgnoreCase)) return "Admin";
        if (v.Equals("Test Engineering", StringComparison.OrdinalIgnoreCase) || v.Equals("Engineer", StringComparison.OrdinalIgnoreCase)) return "Test Engineering";
        if (v.Equals("Quality", StringComparison.OrdinalIgnoreCase)) return "Quality";
        if (v.Equals("Tester", StringComparison.OrdinalIgnoreCase) || v.Equals("Technician", StringComparison.OrdinalIgnoreCase) || v.Equals("Operator", StringComparison.OrdinalIgnoreCase)) return "Tester";
        if (v.Equals("Viewer", StringComparison.OrdinalIgnoreCase)) return "Viewer";
        return "Viewer";
    }

    private int ParseInt(string s, int d) { int v; return int.TryParse(s, out v) ? v : d; }

    private void RegisterProductionLinesScript()
    {
        try
        {
            var productionLines = GetProductionLines();
            if (productionLines != null && productionLines.Rows.Count > 0)
            {
                var jsArray = new System.Text.StringBuilder();
                jsArray.Append("[");
                for (int i = 0; i < productionLines.Rows.Count; i++)
                {
                    if (i > 0) jsArray.Append(",");
                    var row = productionLines.Rows[i];
                    jsArray.AppendFormat("{{id:{0},name:\"{1}\"}}", 
                        row["ProductionLineID"], 
                        System.Web.HttpUtility.JavaScriptStringEncode(row["ProductionLineName"].ToString()));
                }
                jsArray.Append("]");

                var script = "console.log('Loading production lines data:', " + jsArray.ToString() + "); window.productionLinesData = " + jsArray.ToString() + ";";
                
                var sm = ScriptManager.GetCurrent(this.Page);
                if (sm != null)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ProductionLinesData", script, true);
                else
                    ClientScript.RegisterStartupScript(this.GetType(), "ProductionLinesData", script, true);
            }
            else
            {
                var script = "console.log('No production lines found in database'); window.productionLinesData = [];";
                var sm = ScriptManager.GetCurrent(this.Page);
                if (sm != null)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ProductionLinesData", script, true);
                else
                    ClientScript.RegisterStartupScript(this.GetType(), "ProductionLinesData", script, true);
            }
        }
        catch (Exception ex)
        {
            var script = "console.log('Error loading production lines:', '" + ex.Message.Replace("'", "\\'") + "'); window.productionLinesData = [];";
            var sm = ScriptManager.GetCurrent(this.Page);
            if (sm != null)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "ProductionLinesData", script, true);
            else
                ClientScript.RegisterStartupScript(this.GetType(), "ProductionLinesData", script, true);
        }
    }

    private DataTable GetProductionLines()
    {
        var cs = ConfigurationManager.ConnectionStrings["TestEngineeringConnectionString"].ConnectionString;
        using (var conn = new SqlConnection(cs))
        using (var cmd = new SqlCommand("SELECT ProductionLineID, ProductionLineName FROM ProductionLine WHERE IsActive = 1 ORDER BY ProductionLineName", conn))
        {
            conn.Open();
            var table = new DataTable();
            using (var adapter = new SqlDataAdapter(cmd))
            {
                adapter.Fill(table);
            }
            return table;
        }
    }
}
