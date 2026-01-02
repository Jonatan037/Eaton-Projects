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


public partial class Tracks_Reports_DeviceHistory_PCaT_Instruction_Name : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {
        DataTable dt;
        string sql = "";

        lblDebug.Text = "";

        if (txtCriteria.Text == "")
        {
            lblDebug.Text = "Instruction name is required!";
            return;
        }

        sql = "SELECT * FROM vw_TDM_TEST_RESULTS WHERE InstructionName = '" + txtCriteria.Text + "'";

        dt = GetData(sql);


        Tools t = new Tools();
        t.CreateExcelFile("InstructionName", ref dt);

        //lblDebug.Text = sql + "\r\n" + dt.Rows.Count.ToString();

    }

    private DataTable GetData(string sql)
    {
        string _constr = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;


        DataTable dt = new DataTable();


        try
        {
            using (SqlConnection con = new SqlConnection(_constr))
            {
                using (SqlCommand cmd = new SqlCommand(sql))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter())
                    {
                        cmd.Connection = con;
                        sda.SelectCommand = cmd;
                        sda.Fill(dt);
                    }
                }
            }


        }
        catch (SqlException ex)
        {
            lblDebug.Text = ex.Message;
        }

        return dt;

    }
    
}