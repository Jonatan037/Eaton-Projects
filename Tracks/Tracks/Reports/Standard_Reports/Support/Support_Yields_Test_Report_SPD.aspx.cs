using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.IO;

using Tracks.DAL;


public partial class Tracks_Reports_Standard_Reports_Support_Support_Yields_Test_Report : System.Web.UI.Page
{

    protected void Page_Load(object sender, EventArgs e)
    {

        string dbid = Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()].ToString();
        string results_id = Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()].ToString();

        Response.Redirect("http://166.99.61.24/Production_Queries/TestReport/GetRecord.asp?ID=" + results_id);
        return;

        string serial_number = GetSerailNumberFromDatabase(dbid, results_id);



        HyperLink1.Text = serial_number;
        HyperLink1.NavigateUrl = "http://166.99.61.24/Production_Queries/FindUnit/FindUnit.Asp?frmSerialNumber=" + serial_number;

    }


    private string GetSerailNumberFromDatabase(string DBID, string ResultsID)
    {

        string serial_number = "";

        string connection_string = ConfigurationManager.ConnectionStrings["QDMSConnectionString"].ConnectionString;

        string sql = "SELECT SerialNumber FROM [qdms_master_index] WHERE [DBID] = " + DBID + " AND [ResultsID] = " + ResultsID;

        try
        {
            using (SqlConnection con = new SqlConnection(connection_string))
            {
                using (SqlCommand cmd = new SqlCommand(sql))
                {
                    cmd.Connection = con;
                    con.Open();

                    serial_number = cmd.ExecuteScalar().ToString();

                    con.Close();
                }
            }
        }
        catch (Exception ex)
        {
            serial_number = "xxx";
            lblDebug.Text = ex.Message.ToString() + "  " + sql;
        }

        return serial_number;
    }





}