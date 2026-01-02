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

public partial class Tracks_Reports_TDM_Where_Used : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {

    }



    private DataTable GetServerData()
    {
        string connection_string = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;        
        string sql;

        DataTable dtResults = new DataTable();

        //TestRunId	FacilityId	LineName	WorkstationName	ParentStationName	ModelNumber	SerialNumber	ShiftName	OperatorName	Passed	StartTime	StartDate	TestRunSpan	TestRunTypeID	TestRunType


        sql = "SELECT SerialNumber, ModelNumber,LineName,ParentStationName,WorkstationName, Passed,	StartTime, TestRunId, 40 AS [DBID] " + 
              "FROM [vw_PCaT_TestResultRun_DataDog] WHERE [TestRunId] IN " +
              "( " +
                  "SELECT [ResultRunId] FROM [Results] WHERE id IN " +
                     "(SELECT [ResultsId] FROM [ResultsString] WHERE [Results] LIKE '%" + TextBox1.Text + "%') " +
              ")";


        try
        {
            using (SqlConnection con = new SqlConnection(connection_string))
            {
                using (SqlCommand cmd = new SqlCommand(sql))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        sda.Fill(dtResults);

                    }
                }
            }


        }
        catch (SqlException ex)
        {
            GridView1.EmptyDataText = ex.Message.ToString() + "<br>" + sql;
            lblSQL.Text = "";
        }

        lblSQL.Text = sql;

        return dtResults;

    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {

        // Set a minimum limit on the search criteria.
        if (TextBox1.Text.Trim().Length < 5)
        {
            GridView1.EmptyDataText = "Miniumn length of search criteria is 5 characters.";
            GridView1.DataSource = null;
            GridView1.DataBind();
            lblSQL.Text = "";
            return;
        }


        // Reset the empty data text to default.
        GridView1.EmptyDataText = "No data found for the specified search criteria.";


        TextBox1.Text = TextBox1.Text.Trim();
        TextBox1.Text = TextBox1.Text.ToUpper();

        GridView1.DataSource = GetServerData();
        GridView1.DataBind();

    }

    protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);


        // Get the data key values.
        string serial_number = GridView1.DataKeys[index].Values["SerialNumber"].ToString();
        string dbid = GridView1.DataKeys[index].Values["DBID"].ToString();
        //string index_id = GridView1.DataKeys[index].Values["IndexID"].ToString();
        string results_id = GridView1.DataKeys[index].Values["TestRunId"].ToString();
        //string record_type = GridView1.DataKeys[index].Values["RecordType"].ToString();

        string redirect = "";
        string url = "";



        // Reset the grid rows to default background colors.
        for (int ctr = 0; ctr < GridView1.Rows.Count; ctr++)
        {
            if (ctr % 2 == 0)
                GridView1.Rows[ctr].BackColor = System.Drawing.Color.White;
            else
                GridView1.Rows[ctr].BackColor = System.Drawing.Color.LightGray;
        }

        // Set the selected row background.
        GridView1.Rows[index].BackColor = System.Drawing.Color.Yellow;


        if (e.CommandName == "History")
        {

            Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = serial_number ;

            //Response.Redirect("~/Tracks/Reports/DeviceHistory/Device_History.aspx");

            url = ResolveUrl("~/Tracks/Reports/DeviceHistory/Device_History.aspx");

            redirect = "<script>window.open('" + url + "');</script>";
            Response.Write(redirect);
        }



        // Show the details 
        if (e.CommandName == "Record")
        {

            Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()] = dbid;
            Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()] = results_id;

            url = ResolveUrl("~/Tracks/Reports/Standard_Reports/Support/Support_Yields_Test_Report.aspx");

            redirect = "<script>window.open('" + url + "');</script>";
            Response.Write(redirect);
        }


    }

}