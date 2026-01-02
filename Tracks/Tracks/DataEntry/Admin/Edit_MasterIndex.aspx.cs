using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

public partial class Tracks_DataEntry_Admin_Edit_MasterIndex : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        ucSearch.SerialNumberFound += new EventHandler(DataBind);
    }


    protected void DataBind(object sender, EventArgs e)
    {
        HiddenField1.Value = ucSearch.SerialNumber;
    }


    protected void DetailsView1_ItemCreated(object sender, EventArgs e)
    {

        if (DetailsView1.Rows.Count == 0) return;

        // Test FooterRow to make sure all rows have been created 
        if (DetailsView1.FooterRow != null)
        {
            // The command bar is the last element in the Rows collection
            int commandRowIndex = DetailsView1.Rows.Count - 1;
            DetailsViewRow commandRow = DetailsView1.Rows[commandRowIndex];

            // Look for the DELETE button
            DataControlFieldCell cell = (DataControlFieldCell)commandRow.Controls[0];
            foreach (Control ctl in cell.Controls)
            {
                LinkButton link = ctl as LinkButton;
                if (link != null)
                {
                    if (link.CommandName == "Delete")
                    {
                        link.ToolTip = "Click here to delete";
                        link.OnClientClick = "return confirm('Do you really want to delete this record?');";
                    }
                }
            }
        }
    }

    protected void btnUpdateMetaData_Click(object sender, EventArgs e)
    {
        MasterIndex mi = new MasterIndex();
        mi.UpdateMetaData(HiddenField1.Value);
        DetailsView1.DataBind();

    }
}