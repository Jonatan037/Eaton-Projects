using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using Tracks.DAL;
using Tracks.BLL;

public partial class Tracks_Protected_IssueReports_Edit : System.Web.UI.Page
{
    #region Declarations

    // ViewState names
    const string vsUrl = "URL";
    const string vsIssueReportID = "IssueReportID";


    string home_page = "Create_IssueReports.aspx";

    string edit_page_components = "Edit_Components.aspx";

    string edit_page_labor_hours = "Edit_LaborHours.aspx";

    string edit_page_corrective_actions = "Edit_CorrectiveActions.aspx";

    string edit_page_files = "Edit_Files.aspx";

    private struct PanelCollapsedState
    {
        public bool ProblemDescription;
        public bool Notes;
        public bool ReworkInstruction;
        public bool Components;
        public bool LaborHours;
        public bool QualityDept;
        public bool Files;
    }

    #endregion

    #region Data
    protected void Page_Load(object sender, EventArgs e)
    {

        SetPanelState();

        if (!IsPostBack)
        {
            IssueReports IR = new IssueReports();
            string issue_report_id = "";
            string master_index_id = "";
            string serial_number = "";
            string plant = "";
            string family = "";
            string category = "";


            // Try to get the url of the calling page.
            //if (Request.UrlReferrer != null)
            //ViewState[vsUrl] = Request.UrlReferrer.ToString();

            // Get the issue report id number form the session variable.
            issue_report_id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()].ToString();

            ViewState[vsIssueReportID] = issue_report_id;

            if (ViewState[vsIssueReportID] != null)
            {
                IR.GetMasterIndexInfo(issue_report_id, ref master_index_id, ref serial_number, ref plant, ref family, ref category);

                GetData();
            }

            // If the serial number is avaliable, then populate text boxes.
            if (serial_number != "")
            {
                Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number;

                lblTitle.Text = "Edit issue report for serial number " + serial_number;
            }


            // Hide/Unhide controls based on user roles.
            pnlOptions.Visible = UserPermissions.CanEditQualityOptions(User);


            // Hide/Unhide controls based on user roles.
            btnDelete.Visible = UserPermissions.CanDeleteIssueReport(User);

            pnl_TEST_ENGINEERING_OPIONS.Visible = UserPermissions.IsAdministrator(User);

        }
    }

    private void PopulateAssemblyStationDropList()
    {
        DbAccess db = new DbAccess();

        string issue_report_id = issue_report_id = Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()].ToString();
        string master_index_id = "";
        string serial_number = "";
        string plant = "";
        string family = "";

        string category = "";
        IssueReports IR = new IssueReports();
        IR.GetMasterIndexInfo(issue_report_id, ref master_index_id, ref serial_number, ref plant, ref family, ref category);
        //string sql = "SELECT [STATION_NAME] FROM ISSUE_REPORTS_CT_ASSEMBLY_STATION WHERE [LINE_NAME] = '" + family + "' AND ACTIVE = 1 ORDER BY STATION_NAME";

        string sql = "SELECT [STATION_NAME] FROM ISSUE_REPORTS_CT_ASSEMBLY_STATION_NAMES ORDER BY STATION_NAME";

        DataTable dt = db.GetData(sql);

        ddl_ASSEMBLY_STATION.DataSource = dt;

        ddl_ASSEMBLY_STATION.DataTextField = "STATION_NAME";

        ddl_ASSEMBLY_STATION.DataValueField = "STATION_NAME";

        ddl_ASSEMBLY_STATION.DataBind();

        ddl_ASSEMBLY_STATION.Items.Insert(0, "----");

        
    }


    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";
        bool closed = false;
        bool locked = false;

        // -------------------------------------------------------------------------------------------------------------
        // Drop lists
        PopulateAssemblyStationDropList();

        db.PopulateDropDownList(ddl_NONCONFORMANCE_CODE, DbAccess.DropListType.ISSUE_REPORTS_CT_NONCONFORMANCE_CODE);        
        db.PopulateDropDownList(ddl_ROOT_CAUSE_CODE, DbAccess.DropListType.ISSUE_REPORTS_CT_ROOT_CAUSE_CODE);
        db.PopulateDropDownList(ddl_STATION_TYPE, DbAccess.DropListType.ISSUE_REPORTS_CT_STATION_TYPE);
        db.PopulateDropDownList(ddl_STATUS, DbAccess.DropListType.ISSUE_REPORTS_CT_STATUS);

        // -------------------------------------------------------------------------------------------------------------

        sql = "SELECT * FROM [ISSUE_REPORTS] WHERE [ISSUE_REPORTS_ID] = " + ViewState[vsIssueReportID].ToString();

        dt = db.GetData(sql);

        txt_PROBLEM_DESCRIPTION.Text = dt.Rows[0]["PROBLEM_DESCRIPTION"].ToString();

        txt_NOTES.Text = dt.Rows[0]["NOTES"].ToString();

        txt_REWORK_INSTRUCTIONS.Text = dt.Rows[0]["REWORK_INSTRUCTIONS"].ToString();


        txt_BUILDER.Text = dt.Rows[0]["BUILDER"].ToString();
        txt_VERIFIER.Text = dt.Rows[0]["VERIFIER"].ToString();


        closed = (bool) dt.Rows[0]["CLOSED"];
        locked = (bool)dt.Rows[0]["LOCKED"];
        
        cbClosed.Checked = closed;
        cbLocked.Checked = locked;

        try
        {
            db.DropDownList_SelectedValue( ddl_NONCONFORMANCE_CODE, dt.Rows[0]["NONCONFORMANCE_CODE"].ToString() );
            db.DropDownList_SelectedValue( ddl_ROOT_CAUSE_CODE, dt.Rows[0]["ROOT_CAUSE_CODE"].ToString() );
            db.DropDownList_SelectedValue( ddl_STATION_TYPE,dt.Rows[0]["STATION_TYPE"].ToString() );
            db.DropDownList_SelectedValue(ddl_STATUS, dt.Rows[0]["STATUS"].ToString());
            db.DropDownList_SelectedValue(ddl_ASSEMBLY_STATION, dt.Rows[0]["ASSEMBLY_STATION"].ToString());

        }
        catch(Exception ex)
        {
            lblDebug.Text = ex.Message;
        }


        // -------------------------------------------------------------------------------------------------------------

        sql = "SELECT * FROM [COMPONENTS] WHERE [ISSUE_REPORTS_ID] = " + ViewState[vsIssueReportID].ToString();

        //lblDebug.Text = sql;

        dt = db.GetData(sql);

        gvComponents.DataSource = dt;
        gvComponents.DataBind();

        // -------------------------------------------------------------------------------------------------------------

        sql = "SELECT * FROM [LABOR_HOURS] WHERE [ISSUE_REPORTS_ID] = " + ViewState[vsIssueReportID].ToString();

        //lblDebug.Text = sql;

        dt = db.GetData(sql);

        gvLaborHours.DataSource = dt;
        gvLaborHours.DataBind();

        // -------------------------------------------------------------------------------------------------------------

        sql = "SELECT * FROM [CORRECTIVE_ACTIONS] WHERE [ISSUE_REPORTS_ID] = " + ViewState[vsIssueReportID].ToString();

        //lblDebug.Text = sql;

        dt = db.GetData(sql);

        gvCorrectiveActions.DataSource = dt;
        gvCorrectiveActions.DataBind();


        // -------------------------------------------------------------------------------------------------------------

        FileStorage FS = new FileStorage();

        //sql = "SELECT * FROM [FILE_STORAGE] WHERE [ISSUE_REPORTS_ID] = " + ViewState[vsIssueReportID].ToString();

        //lblDebug.Text = sql;

        //dt = db.GetData(sql);

        dt = FS.GetData(ViewState[vsIssueReportID].ToString());

        foreach (DataRow row in dt.Rows)
        {
            row["NOTES"] = row["NOTES"].ToString().Replace(System.Environment.NewLine, "<BR>");
        }
    
        gvFiles.DataSource = dt;
        gvFiles.DataBind();


#if true
        if (locked)
        {
            pnl_PROBLEM_DESCRIPTION.Enabled = !locked;
            pnl_NOTES.Enabled = !locked;
            pnl_COMPONENTS.Enabled = !locked;
            pnl_LABOR_HOURS.Enabled = !locked;
            pnl_NOTES_INSTRUCTIONS_UPM_LINE.Enabled = !locked;
            pnl_QUALITY_DEPT_OPTIONS.Enabled = !locked;
            pnl_REWORK_INSTRUCTIONS.Enabled = !locked;
            pnl_FILES.Enabled = !locked;
            //pnlOptions.Enabled = !locked;
            pnl_Buttons.Enabled = !locked;
            pnl_ComboBoxes.Enabled = !locked;

        // Allow an administration access to the buttons even if the report is locked.
        pnl_Buttons.Enabled = UserPermissions.IsAdministrator(User);


        }
#endif


    }





    private void SaveBeforeExit(string url)
    {
        bool status;

        IssueReports IR = new IssueReports();

        status = IR.Update
        (
            ViewState[vsIssueReportID].ToString(),
            txt_PROBLEM_DESCRIPTION.Text,
            txt_NOTES.Text,
            txt_REWORK_INSTRUCTIONS.Text,
            ddl_NONCONFORMANCE_CODE.SelectedValue,
            ddl_STATION_TYPE.SelectedValue,
            ddl_ROOT_CAUSE_CODE.SelectedValue,
            ddl_STATUS.SelectedValue,
            cbClosed.Checked, 
            ddl_ASSEMBLY_STATION.SelectedValue,
            txt_BUILDER.Text,
            txt_VERIFIER.Text,
            cbLocked.Checked
        );

        if (!status)
        {
            lblDebug.Text = IR.ErrorMessage;
            return;
        }

        Redirect(url);
    }

    #endregion

    #region PanelState
    private void SetPanelState()
    {

        try
        {
            if (Session[DbAccess.SessionVariableName.ISSUE_REPORT_PANEL_STATE.ToString()] == null) return;

            PanelCollapsedState PCS;

            // Get the panel state from the session variable.
            PCS = (PanelCollapsedState)Session[DbAccess.SessionVariableName.ISSUE_REPORT_PANEL_STATE.ToString()];

            cpe_PROBLEM_DESCRIPTION.Collapsed = PCS.ProblemDescription;
            cpe_NOTES.Collapsed = PCS.Notes;
            cpe_REWORK_INSTRUCTIONS.Collapsed = PCS.ReworkInstruction;
            cpe_COMPONENTS.Collapsed = PCS.Components;
            cpe_LABOR_HOURS.Collapsed = PCS.LaborHours;
            cpe_QUALITY_DEPT_OPTIONS.Collapsed = PCS.QualityDept;
            cpe_FILES.Collapsed = PCS.Files;
        }
        catch
        {
            Session[DbAccess.SessionVariableName.ISSUE_REPORT_PANEL_STATE.ToString()] = null;
        }

    }

    private void SavePanelState()
    {
        PanelCollapsedState PCS;

        PCS.ProblemDescription = bool.Parse(cpe_PROBLEM_DESCRIPTION.ClientState);
        PCS.Notes = bool.Parse(cpe_NOTES.ClientState);
        PCS.ReworkInstruction = bool.Parse(cpe_REWORK_INSTRUCTIONS.ClientState);
        PCS.Components = bool.Parse(cpe_COMPONENTS.ClientState);
        PCS.LaborHours = bool.Parse(cpe_LABOR_HOURS.ClientState);
        PCS.Files = bool.Parse(cpe_FILES.ClientState);
        PCS.QualityDept = false;

        // Null if the panel is not visible.
        //PCS.QualityDept = bool.Parse(cpe_QUALITY_DEPT_OPTIONS.ClientState);

        // Save to session variable.
        Session[DbAccess.SessionVariableName.ISSUE_REPORT_PANEL_STATE.ToString()] = PCS;
    }

    private void Redirect(string url)
    {
        SavePanelState();

        Response.Redirect(url);
    }

    #endregion

    #region Buttons

    protected void btnSave_Click(object sender, EventArgs e)
    {
        SaveBeforeExit(home_page);
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        Redirect(home_page);
    }


    protected void btnDelete_Click(object sender, EventArgs e)
    {
        IssueReports ir = new IssueReports();
        ir.Delete(ViewState[vsIssueReportID].ToString());

        Redirect(home_page);
    }

    protected void btn_PROBLEM_DESCRIPTION_Click(object sender, EventArgs e)
    {
        AppendTimestamp(txt_PROBLEM_DESCRIPTION);
        
    }

    protected void btn_NOTES_Click_Click(object sender, EventArgs e)
    {
        AppendTimestamp(txt_NOTES);
    }


    protected void btn_REWORK_INSTRUCTIONS_Click(object sender, EventArgs e)
    {
        AppendTimestamp(txt_REWORK_INSTRUCTIONS);
    }


    private void AppendTimestamp(TextBox TB)
    {
        TB.Text += "\r\nModified on " + DateTime.Now + " by " + User.Identity.Name.ToUpper() + "\r\n";
    }

    protected void btnPrint_Click(object sender, EventArgs e)
    {
        SaveBeforeExit("~/Tracks/Print/PrintIssueReport.aspx");
    }



    protected void btn_PRINT_REWORK_INSTRUCTIONS_Click(object sender, EventArgs e)
    {
        SaveBeforeExit("~/Tracks/Print/PrintReworkInstructions.aspx");
    }

    #endregion
    
    #region Components

    protected void gvComponents_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (gvComponents.SelectedDataKey.Value == null) return;

        string report_id = gvComponents.SelectedDataKey.Value.ToString();

        Session[ DbAccess.SessionVariableName.COMPONENT_ID.ToString() ] = report_id;

        SaveBeforeExit(edit_page_components);

    }



    protected void btnAddComponent_Click(object sender, EventArgs e)
    {
        // Set the COMPONENTS_ID to 0 to indicate that a new component should be added.
        Session[ DbAccess.SessionVariableName.COMPONENT_ID.ToString() ] = "0";

        SaveBeforeExit(edit_page_components);
    }

    #endregion

    #region LaborHours
    protected void btnAddLaborHours_Click(object sender, EventArgs e)
    {
        // Set the LABOR_HOUR_ID to 0 to indicate that a new entry should be added.
        Session[DbAccess.SessionVariableName.LABOR_HOUR_ID.ToString()] = "0";

        SaveBeforeExit(edit_page_labor_hours);
    }

    protected void gvLaborHours_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (gvLaborHours.SelectedDataKey.Value == null) return;

        string report_id = gvLaborHours.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.LABOR_HOUR_ID.ToString()] = report_id;

        SaveBeforeExit(edit_page_labor_hours);
    }

    #endregion

    #region CorrectiveActions
    protected void btnAddCorrectiveActions_Click(object sender, EventArgs e)
    {
        // Set the CORRECTIVE_ACTION_ID to 0 to indicate that a new entry should be added.
        Session[DbAccess.SessionVariableName.CORRECTIVE_ACTION_ID.ToString()] = "0";

        SaveBeforeExit(edit_page_corrective_actions);
    }

    protected void gvCorrectiveActions_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvCorrectiveActions.SelectedDataKey.Value == null) return;

        string report_id = gvCorrectiveActions.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.CORRECTIVE_ACTION_ID.ToString()] = report_id;

        SaveBeforeExit(edit_page_corrective_actions);
    }

    #endregion


    #region Files

    protected void gvFiles_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (gvFiles.SelectedDataKey.Value == null) return;

        string report_id = gvFiles.SelectedDataKey.Value.ToString();

        Session[DbAccess.SessionVariableName.FILE_ID.ToString()] = report_id;

        SaveBeforeExit(edit_page_files);
    }



    protected void btnAddFiles_Click(object sender, EventArgs e)
    {
        // Set the FILE_ID to 0 to indicate that a new file should be added.
        Session[DbAccess.SessionVariableName.FILE_ID.ToString()] = "0";

        SaveBeforeExit(edit_page_files);
    }

    #endregion
}