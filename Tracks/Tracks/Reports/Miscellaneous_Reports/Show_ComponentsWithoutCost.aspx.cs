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
public partial class Tracks_Reports_Miscellaneous_Reports_Show_ComponentsWithoutCost : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            string sql;

            sql = "SELECT PART_NUMBER, DESCRIPTION, COST FROM COMPONENTS " +
                  "GROUP BY PART_NUMBER, DESCRIPTION, COST " +
                  "HAVING COST = 0";


            DbAccess db = new DbAccess();
            DataTable dt;

            dt = db.GetData(sql);

            Label1.Text = "There are " + dt.Rows.Count.ToString() + " part numbers in the list.";

            GridView1.DataSource = dt;
            GridView1.DataBind();

        }
    }
}