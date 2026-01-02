using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


using System.Data;
using System.Configuration;
using System.Data.SqlClient;


public partial class Tracks_Reports_TDM_Details : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string id = Request.QueryString["TestRunId"].ToString();

            GridView1.DataSource = GetData(id);
            GridView1.DataBind();
        }
    }

    private DataTable GetData(string TestRunId)
    {
        string _constr = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;

        string sql;

        DataTable dt = new DataTable();

        sql = "SELECT * FROM [TDMEnterprise].[dbo].[tbl_ALLResult_view] where [ResultRunId] = " + TestRunId + "  order by [Sequence_Number]";

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

        }
        return dt;

    }

}