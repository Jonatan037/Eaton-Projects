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

using System.Drawing;   // Has the definitions for colors.

public partial class Tracks_Reports_DeviceHistory_Device_History : System.Web.UI.Page
{



    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {

            try
            {
                txtCriteria.Text = Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()].ToString();
                btnFind_Click(sender, e);
            }
            catch
            {

            }

        }
    }




    protected void btnFind_Click(object sender, EventArgs e)
    {
        txtCriteria.Text = txtCriteria.Text.Trim();
        txtCriteria.Text = txtCriteria.Text.ToUpper();

        // Require 5 characters minimum for serial number.
        if (txtCriteria.Text.Length < 5)
        {
            gvHistory.DataSource = null;
            gvHistory.DataBind();
            return;
        }

        DbAccess dba = new DbAccess();

        string sql = "";
        string criteria = "";

        criteria = " LIKE '%" + txtCriteria.Text + "%' ";


        // Default statement.
        sql = "" +
            "SELECT " +
                "SERIAL_NUMBER [SerialNumber], " +
                "FIRST_TEST_DATE [Date], " +
                "'TRACKS Master Index' [Source], " +
                "PLANT [Plant], " +
                "FAMILY [Family], " +
                "CATEGORY [Category], " +
                "PART_NUMBER [PartNumber], " +
                "IIF( [FAILED] = 1, 'Failed', 'Passed') [Status], " +
                "'Tracks' [RecordType], " +
                "'' [Note], " +
                "0 [DBID], " +
                "MASTER_INDEX_ID [IndexID], " +
                "0 [ResultsID], " +
                "'' [ParentStation], " +
                "'' [ChildStation] " +
            "FROM View_PowerBI_MASTER_INDEX WHERE SERIAL_NUMBER " + criteria +
            "UNION " +
            "SELECT " +
                "SerialNumber [SerialNumber], " +
                "StartTime [Date], " +
                "'QDMS' [Source], " +
                "PLANT [Plant], " +
                "FAMILY [Family], " +
                "CATEGORY [Category], " +
                "PartNumber [PartNumber], " +
                "[TestResult] [Status], " +
                "[Record Type] [RecordType], " +
                "IIF( [DBID] = 40, [Info4Item], '') [Note], " +
                "DBID [DBID], " +
                "INDEXID[IndexID], " +
                "ResultsID [ResultsID], " +
                "IIF( [DBID] = 40, [Info2Item], '') [ParentStation], " +
                "IIF( [DBID] = 40, [Info3Item], '') [ChildStation] " +
            "FROM [View_PowerBI_QDMS_INDEX_VIEW] WHERE SerialNumber " + criteria +
            "UNION " +
            "SELECT " +
                "SERIAL_NUMBER [SerialNumber], " +
                "[ISSUE_DATE] [Date], " +
                "'TRACKS Issue Report' [Source], " +
                "PLANT [Plant], " +
                "FAMILY [Family], " +
                "CATEGORY [Category], " +
                "PART_NUMBER [PartNumber], " +
                "'Failed' [Status], " +
                "'Tracks' [RecordType], " +
                "''[Note], " +
                "0 [DBID], " +
                "MASTER_INDEX_ID [IndexID], " +
                "0 [ResultsID], " +
                "'' [ParentStation], " +
                "'' [ChildStation] " +
            "FROM View_PowerBI_MASTER_INDEX_AND_ISSUE_REPORTS_COMBINED WHERE SERIAL_NUMBER " + criteria;

        sql += "ORDER BY [SerialNumber], [Date]";


        gvHistory.DataSource = dba.GetData(sql);
        gvHistory.DataBind();
    }



    protected void gvHistory_RowCommand(object sender, GridViewCommandEventArgs e)
    {

        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);

        string redirect = "";
        string url = "";

        // Reset the grid rows to default background colors.
        for (int ctr = 0; ctr < gvHistory.Rows.Count; ctr++)
        {
            if (ctr % 2 == 0)
                gvHistory.Rows[ctr].BackColor = Color.White;
            else
                gvHistory.Rows[ctr].BackColor = Color.LightGray;
        }

        // Set the selected row background.
        gvHistory.Rows[index].BackColor = Color.Yellow;

        // Get the data key values.
        string serial_number = gvHistory.DataKeys[index].Values["SerialNumber"].ToString();
        string dbid = gvHistory.DataKeys[index].Values["DBID"].ToString();
        string index_id = gvHistory.DataKeys[index].Values["IndexID"].ToString();
        string results_id = gvHistory.DataKeys[index].Values["ResultsID"].ToString();
        string record_type = gvHistory.DataKeys[index].Values["RecordType"].ToString();


        if (dbid == "0")
        {
            Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number;

            //    <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/Tracks/Reports/Standard_Reports/Search.aspx">HyperLink</asp:HyperLink>

            url = ResolveUrl("~/Tracks/Reports/Standard_Reports/Search.aspx");

            //redirect = "<script>window.open('Search');</script>";
            redirect = "<script>window.open('" + url +"');</script>";
            Response.Write(redirect);

        }
        else
        {
            Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()] = dbid;
            Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()] = results_id;
            
   
            //redirect = "<script>window.open('~/Tracks/Reports/Standard_Reports/Support/Support_Yields_Test_Report.aspx');</script>";
            //Tracks/Reports/DeviceHistory/Reports/Standard_Reports/Support/Support_Yields_Test_Report.aspx
            //Tracks/Reports/DeviceHistory/~/Tracks/Reports/Standard_Reports/Support/Support_Yields_Test_Report.aspx

            url = ResolveUrl("~/Tracks/Reports/Standard_Reports/Support/Support_Yields_Test_Report.aspx");

            if (dbid != "0")
            {
                redirect = "<script>window.open('" + url +"');</script>";
                Response.Write(redirect);
            }

        }

    }
    
    



}