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



public partial class Tracks_Reports_Standard_Reports_Support_Support_PartNumber_Lookup : System.Web.UI.Page
{

    // Dropdown list name and database field name.
    private enum ddlFILTER
    {
        PLANT,
        FAMILY,
        CATEGORY,
        SUBCATEGORY,
        MATERIAL_TYPE

    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            PopulateCategoryList();
            ResetFilters();
            //GetData();
        }

    }

    private void PopulateCategoryList()
    {
        DbAccess db = new DbAccess();
        string sql;

        sql = "SELECT DISTINCT CATEGORY FROM PART_NUMBERS WHERE ( INCLUDE_IN_LOOKUP = 1 ) ORDER BY CATEGORY";

        ddlCategory.DataSource = db.GetData(sql);

        ddlCategory.DataValueField = "CATEGORY";
        ddlCategory.DataTextField = "CATEGORY";
        ddlCategory.DataBind();
    }

    private void ResetFilters()
    {
        foreach (string name in Enum.GetNames(typeof(ddlFILTER)))
        {
            ViewState[name] = "";
        }
    }

    protected void btnReset_Click(object sender, EventArgs e)
    {
        ResetFilters();
        GetData();
    }


    private string GetFilter(ddlFILTER Filter)
    {
        string return_value = "";
        string filter_name = Filter.ToString();

        // Create statement to use the filer name and value.
        if (ViewState[filter_name].ToString() != "")
            return_value = "AND (" + filter_name + " = '" + ViewState[filter_name].ToString() + "') ";

        return return_value;
    }


    private void GetData()
    {
        string selection = "SELECT PART_NUMBER, PLANT, FAMILY, CATEGORY, SUBCATEGORY, VENDOR_PART_NUMBER, COST, MATERIAL_TYPE, SERIAL_NUMBER_STARTS_WITH, DESCRIPTION, NOTES FROM PART_NUMBERS ";
        string orderby = " ORDER BY PART_NUMBER";
        string where = "";
        string sql;
        DataTable dt;

        DbAccess db = new DbAccess();

        string criteria = "";

        foreach (ddlFILTER filter in Enum.GetValues(typeof(ddlFILTER)))
        {
            criteria += GetFilter(filter);
        }

        if (RadioButtonList1.SelectedValue == "liComponentText")
        {
            //string text = "'%" + txtSearchCriteria.Text + "%'";
            string text = txtSearchCriteria.Text;

            //where = "WHERE ( ( PART_NUMBER LIKE '" + text + "%' ) OR ( VENDOR_PART_NUMBER LIKE '%" + text + "%' ) OR ( SERIAL_NUMBER_STARTS_WITH LIKE '%" + text + "%' )  OR (Left( '" + text + "', Len( [SERIAL_NUMBER_STARTS_WITH] ) ) = [SERIAL_NUMBER_STARTS_WITH] ) ) " + criteria;

            where = "WHERE " +
                    "( " +
                       "( PART_NUMBER LIKE '" + text + "%' ) OR " +
                       "( VENDOR_PART_NUMBER LIKE '%" + text + "%' ) OR " +
                       "( SERIAL_NUMBER_STARTS_WITH LIKE '%" + text + "%' )  OR " +
                       "(Left( '" + text + "', Len( [SERIAL_NUMBER_STARTS_WITH] ) ) = [SERIAL_NUMBER_STARTS_WITH] ) OR " +
                       "(Left( '" + text + "', Len( [VENDOR_PART_NUMBER] ) ) = [VENDOR_PART_NUMBER] ) " +
                    ") " +
                    criteria;

            string temp;



        }
        else
        {
            //where = "WHERE ( INCLUDE_IN_LOOKUP = 1 ) AND CATEGORY = '" + ddlCategory.SelectedValue.ToString() + "' " + criteria;
            where = "WHERE CATEGORY = '" + ddlCategory.SelectedValue.ToString() + "' " + criteria;
        }


        sql = selection + where + orderby;

        //lblDebug.Text = sql;

        dt = db.GetData(sql);

        GridView1.DataSource = dt;
        GridView1.DataBind();

        foreach (ddlFILTER filter in Enum.GetValues(typeof(ddlFILTER)))
        {
            BindDropDownList(filter, dt);
        }

    }

    private void BindDropDownList(ddlFILTER Filter, DataTable Table)
    {
        string filter_name = Filter.ToString();

        DataTable dt;
        DropDownList ddl;
        ListItem item = new ListItem("ALL", "");

        // Get the data for the specified column
        dt = Table.DefaultView.ToTable(true, filter_name);

        // Sort ascending
        dt.DefaultView.Sort = filter_name + " ASC";
        dt = dt.DefaultView.ToTable();


        // Get the drop down list.
        ddl = (DropDownList)GridView1.HeaderRow.FindControl(filter_name);

        // Bind the data to the drop down list.
        ddl.DataSource = dt;
        ddl.DataTextField = filter_name;
        ddl.DataValueField = filter_name;
        ddl.DataBind();

        // Add "ALL" to top of the list.
        ddl.Items.Insert(0, item);

        // Select value from the list.
        ddl.Items.FindByValue(ViewState[filter_name].ToString()).Selected = true;

    }

    protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList ddlSelection = (DropDownList)sender;

        string filter_name = ddlSelection.ID.ToString();

        ViewState[filter_name] = ddlSelection.SelectedValue;

        GetData();

    }



    protected void btnFind_Click(object sender, EventArgs e)
    {
        ResetFilters();
        GetData();
    }


    protected void RadioButtonList1_SelectedIndexChanged(object sender, EventArgs e)
    {

        if (RadioButtonList1.SelectedValue == "liComponentText")
        {
            txtSearchCriteria.Visible = true;
            ddlCategory.Visible = false;
        }
        else
        {
            txtSearchCriteria.Visible = false;
            ddlCategory.Visible = true;
        }

        ResetFilters();
        GridView1.DataBind();
    }
}