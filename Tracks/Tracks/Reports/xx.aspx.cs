using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Tracks_Reports_xx : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }


    protected void GridView1_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);

        string value = "";

        if (e.CommandName == "Details")
        {

            value =  GridView1.DataKeys[index].Values["TestRunId"].ToString();

            //string url = "TDM_Details?TestRunId=" + index.ToString();
            string url = "TDM_Details?TestRunId=" + value;
            Response.Redirect(url);

        }

    }

}