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

public partial class Tracks_DataEntry_Admin_Edit_PartNumbers : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void btnFind_Click(object sender, EventArgs e)
    {
        GridView1.DataBind();
    }

    protected void btnAdd_Click(object sender, EventArgs e)
    {
        string part_number = txtNewPartNumber.Text;

        part_number = part_number.Trim();
        part_number = part_number.ToUpper();

        if (part_number == "") return;

        PartNumbers pn = new PartNumbers();

        pn.Add(part_number);

        // How the new part number in the grid.
        txtNewPartNumber.Text = "";
        txtPartNumber.Text = part_number;
        GridView1.DataBind();

    }

    protected void GridView1_SelectedIndexChanged(object sender, EventArgs e)
    {

    }

    protected void btnDownload_Click(object sender, EventArgs e)
    {
        DbAccess db = new DbAccess();
        DataTable dt;
        string sql;

        sql = "SELECT * FROM PART_NUMBERS  ORDER BY PART_NUMBER";

        dt = db.GetData(sql);
        

        string attach = "attachment;filename=part_numbers.xls";
        Response.ClearContent();
        Response.AddHeader("content-disposition", attach);
        Response.ContentType = "application/ms-excel";

        if (dt != null)
        {
            foreach (DataColumn dc in dt.Columns)
            {
                Response.Write(dc.ColumnName + "\t");
                //sep = ";";
            }
            Response.Write(System.Environment.NewLine);
            foreach (DataRow dr in dt.Rows)
            {
                for (int i = 0; i < dt.Columns.Count; i++)
                {
                    Response.Write(dr[i].ToString() + "\t");
                }
                Response.Write("\n");
            }
            Response.End();
        }
    }
}