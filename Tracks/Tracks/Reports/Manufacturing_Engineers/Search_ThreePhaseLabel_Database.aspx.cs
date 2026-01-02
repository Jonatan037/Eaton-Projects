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

public partial class Tracks_Reports_Manufacturing_Engineers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            //txtStartDate.Text = DateTime.Now.ToShortDateString();

        }
    }



    private string CreateSql()
    {
        string sql;
        string where = "WHERE ";
        string criteria = txtCriteria.Text.ToUpper().Trim();

        txtCriteria.Text = criteria;

        // Get radio button query type.
        if (rblType.SelectedValue == "1")
        {
            where += "[Serial] Like '%" + criteria + "%' " ;
        }
        else 
        {
            where += "[CONFIG] Like '%" + criteria + "%' ";
        }


        // Create the full sql statement.
        sql = "SELECT * FROM tblArchive " +  where + " ORDER BY [Serial]";

        lblDebug.Text = sql;

        return sql;

    }

    public DataTable GetData(string sql)
    {
        string _constr = ConfigurationManager.ConnectionStrings["ThreePhaseLabelConnectionString"].ConnectionString;

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
            //_error_message = ex.Message.ToString() + "  " + sql;
            //throw new DBAccessException(_error_message);
        }
        return dt;

    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {
        string sql = CreateSql();
        DataTable dt = GetData(sql);

        gvLabels.DataSource = dt;
        gvLabels.DataBind();
    }
}