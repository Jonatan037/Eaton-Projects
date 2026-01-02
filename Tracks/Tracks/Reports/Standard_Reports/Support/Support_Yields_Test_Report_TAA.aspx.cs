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
    const string FILE_PATH = @"\\youncsfp01\data\Test-Eng\ProdTestData\Data_Logs\TAA\Eagle\Reports\10000\";
    //const string FILE_PATH = @"\\youncsfp01\data\Test-Eng\ProdTestData\Data_Logs\TAA\Eagle\Reports\Archive\";

    protected void Page_Load(object sender, EventArgs e)
    {

        string dbid = Session[DbAccess.SessionVariableName.REPORT_DBID.ToString()].ToString();
        string results_id = Session[DbAccess.SessionVariableName.REPORT_RESULTS_ID.ToString()].ToString();

        GetFileNameFromDatabase(dbid, results_id);
    }


    private void GetFileNameFromDatabase(string DBID, string ResultsID)
    {
        //string filename = "BT143V0006 2024-04-04 11-47-12 Passed.xls";
        string filename = "";

        string connection_string = ConfigurationManager.ConnectionStrings["Eagle_ConnectionString"].ConnectionString;

        string sql = "SELECT ReportFileName FROM [Master] WHERE DATADOG_ID = " + ResultsID;

        try
        {
            using (SqlConnection con = new SqlConnection(connection_string))
            {
                using (SqlCommand cmd = new SqlCommand(sql))
                {
                    cmd.Connection = con;
                    con.Open();

                    filename = cmd.ExecuteScalar().ToString() + ".xls";

                    con.Close();
                }
            }

            DownloadFile(filename);

        }
        catch (SqlException ex)
        {
            lblDebug.Text = ex.Message.ToString() + "  " + sql;
        }
    }



    private void DownloadFile(string Filename)
    {
        string full_filename = FILE_PATH + Filename;

        if (System.IO.File.Exists(full_filename))
        {
            byte[] data = System.IO.File.ReadAllBytes(full_filename);

            Response.AddHeader ("Content-Disposition", "attachment; filename=" + Filename);

            //Response.AddHeader ("Content-Length", data.Count.ToString() );

            Response.ContentType = "application/octet-stream";

            Response.BinaryWrite(data);
        }
        else
        {
            lblDebug.Text = "File not found: " + full_filename;
        }
    }

}