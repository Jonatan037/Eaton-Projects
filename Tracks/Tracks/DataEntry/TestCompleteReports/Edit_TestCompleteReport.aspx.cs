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

public partial class Tracks_Protected_TestCompleteReports_Edit_TestCompleteReport : System.Web.UI.Page
{
    // ViewState names
    const string vsUrl = "URL";
    const string vsSerialNumber = "SerialNumber";
    const string vsMasterIndexID = "MasterIndexID";
    const string vsTestCompleteID = "TestCompleteID";

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            // Try to get the url of the calling page.
            if (Request.UrlReferrer != null)
                ViewState[vsUrl] = Request.UrlReferrer.ToString();

            // Try to get the serial number.
            string serial_number = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] as string;

            // If the serial number is avaliable, then populate text boxes.
            if (serial_number != null)
            {
                serial_number = serial_number.Trim();
                serial_number = serial_number.ToUpper();

                lblTitle.Text = "UNIT SERIAL NUMBER = " + serial_number;

            }


            // Get the master index id number form the session variable.
            if (Session[DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString()] != null)
            {
                ViewState[vsMasterIndexID] = Session[DbAccess.SessionVariableName.MASTER_INDEX_ID.ToString()].ToString();
            }


            // Get the test complete report id number form the session variable.
            ViewState[vsTestCompleteID] = Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()].ToString();

            //lblDebug.Text = "Test Complete Report ID = " + test_complete_report_id;

            //if (master_index_id != null)
                if (ViewState[vsTestCompleteID] != null)
                    GetData();

            txtPartNumber.Focus();
        }
    }

    private void GetData()
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql = "";

        string employee_id = User.Identity.Name.ToUpper();

        // put code here to decide on selection if this is a new entry.
        if (ViewState[vsTestCompleteID].ToString() != "0")
            sql = "SELECT * FROM [TEST_COMPLETE_REPORTS] WHERE [TEST_COMPLETE_REPORTS_ID] = " + ViewState[vsTestCompleteID].ToString();
        else
            sql = "SELECT MASTER_INDEX.*, '" + employee_id + "' AS [EMPLOYEE_ID] FROM [MASTER_INDEX] WHERE [MASTER_INDEX_ID] = " + ViewState[vsMasterIndexID].ToString();


        dt = db.GetData(sql);

        if (dt.Rows.Count != 0)
        {
            txtSerialNumber.Text = dt.Rows[0]["SERIAL_NUMBER"].ToString();
            txtPartNumber.Text = dt.Rows[0]["PART_NUMBER"].ToString();
            txtProductionOrderNumber.Text = dt.Rows[0]["PRODUCTION_ORDER_NUMBER"].ToString();
            txtSalesOrderNumber.Text = dt.Rows[0]["SALES_ORDER_NUMBER"].ToString();
            txtEmployeeID.Text = dt.Rows[0]["EMPLOYEE_ID"].ToString();
            txtNotes.Text = dt.Rows[0]["NOTES"].ToString();
        }


        // -----------------------------------------------------------------------------------
        txtEmployeeID.Text = txtEmployeeID.Text.Trim();
        txtEmployeeID.Text = txtEmployeeID.Text.ToUpper();

        if (txtEmployeeID.Text == "")
            txtEmployeeID.Text = employee_id;

    }

    private void Save()
    {
        TestCompleteReports TCR = new TestCompleteReports();

        // New entry
        if (ViewState[vsTestCompleteID].ToString() == "0")
        {
            ViewState[vsTestCompleteID] = TCR.Add
            (
                ViewState[vsMasterIndexID].ToString(),
                txtSerialNumber.Text,
                txtPartNumber.Text,
                txtProductionOrderNumber.Text,
                txtSalesOrderNumber.Text, 
                txtEmployeeID.Text,
                txtNotes.Text

            ).ToString();

            Session[DbAccess.SessionVariableName.TEST_COMPLETE_REPORT_ID.ToString()] = ViewState[vsTestCompleteID].ToString();

            // Create PCaT entry for a new test complete report.
            Create_PCaT_Entry();

        }

        // Update existing entry.
        else
        {
            TCR.Update
            (
                ViewState[vsTestCompleteID].ToString(),
                txtSerialNumber.Text,
                txtPartNumber.Text,
                txtProductionOrderNumber.Text,
                txtSalesOrderNumber.Text,
                txtEmployeeID.Text,
                txtNotes.Text
            );
        }
    }


    protected void Create_PCaT_Entry()
    {
        string SerialNumber = txtSerialNumber.Text.ToUpper();
        string PartNumber = txtPartNumber.Text.ToUpper();
        string EmployeeID = txtEmployeeID.Text.ToUpper();

        MasterIndex mi = new MasterIndex();

        // Only create PCaT entry for units that do NOT require an ATE record.
        if ( mi.GetFlagBySerialNumber(SerialNumber, MasterIndex.FlagName.REQUIRES_ATE_RECORD) ) return;


        // Do not create PCaT entries for these.
        if (PartNumber.StartsWith("9PL")) return;
        if (PartNumber.StartsWith("9PV")) return;
        if (PartNumber.StartsWith("P-103000338")) return;


        string LineName = "SystemsTest";
        string ParentWorkStation = LineName + ".FunctionalTest";
        string WorkstationName = "Tracks";

        string Status = "Passed";
        string TestSequenceName = "TCR_" + ParentWorkStation;
        string InstructionName = TestSequenceName + "_OverallResult";

        DateTime StartTime = DateTime.Now;
        DateTime EndTime = StartTime.AddSeconds(2);

        // TDM Production mode = 1;
        byte ResultType = 1;

        TDM_TestResults tdm = new TDM_TestResults();
        
        // Create a new result entry.
        TDM_TestResultsTestResult r = new TDM_TestResultsTestResult();

        // Add values to the result entry.
        r.Status = Status;
        r.CatalogNumber = PartNumber;
        r.SerialNumber = SerialNumber;
        r.StartTime = StartTime;
        r.EndTime = EndTime;
        r.ResultType = ResultType;
        r.TestSequenceName = TestSequenceName;
        r.InstructionName = InstructionName;
        r.LineName = LineName;
        r.ParentWorkStation = ParentWorkStation;
        r.WorkstationName = WorkstationName;

        r.TestComments = "TRACKS Test Complete Report";

        r.OperatorName = EmployeeID;

        tdm.TestResults.Add(r);

        string filename = SerialNumber + "_TCR_" + PartNumber + "_" + StartTime.ToString("yyyy_MM_dd_HH_mm_ss") + ".xml";

        string path = @"C:\Eaton_TDM\";
        string pending = path + @"Pending\" + filename;
        string archive = path + @"Reports\" + filename;


        System.Xml.Serialization.XmlSerializer xml = new System.Xml.Serialization.XmlSerializer(tdm.GetType());


        try
        {

            // Save the file to the archive (Reports) folder.
            System.IO.TextWriter archive_writer = new System.IO.StreamWriter(archive);
            xml.Serialize(archive_writer, tdm);
            archive_writer.Close();

            // Save the file to the pending folder.
            System.IO.TextWriter pending_writer = new System.IO.StreamWriter(pending);
            xml.Serialize(pending_writer, tdm);
            pending_writer.Close();


        }
        catch (Exception ex)
        {
            lblDebug.Text = ex.Message;
        }


    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        Save();
        
        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        TestCompleteReports TCR = new TestCompleteReports();

        TCR.Delete(ViewState[vsTestCompleteID].ToString());


        // Return to the calling page.
        if (ViewState[vsUrl] != null)
            Response.Redirect(ViewState[vsUrl].ToString());
    }


    protected void btnPrint_Click(object sender, EventArgs e)
    {
        Save();

        Response.Redirect("~/Tracks/Print/PrintTestCompleteReport.aspx");
    }

}