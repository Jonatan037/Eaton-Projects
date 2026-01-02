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

public partial class Tracks_Reports_Standard_Reports_ShowIssuesByDateRange : System.Web.UI.Page
{
    // Dropdown list name and database field name.
    private enum ddlFILTER
    {
        PLANT,
        FAMILY,
        CATEGORY,
        SERIAL_NUMBER,
        PART_NUMBER,
        EMPLOYEE_ID,
        STATION_TYPE,
        NONCONFORMANCE_CODE,
        CLOSED,
        NC_CATEGORY
    }


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

            ResetFilters();
            GetIssues();
        }
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
        GetIssues();
    }

    private string GetFilter(ddlFILTER Filter)
    {
        string return_value = "";
        string filter_name = Filter.ToString();

        // Create statement to use the filer name and value.
        if (ViewState[filter_name].ToString() != "")
        {
            if (filter_name == "NC_CATEGORY")
                return_value = "AND (ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY = '" + ViewState[filter_name].ToString() + "') ";
            else if (filter_name == "CATEGORY")
                return_value = "AND (MASTER_INDEX.CATEGORY = '" + ViewState[filter_name].ToString() + "') ";
            else
                return_value = "AND (" + filter_name + " = '" + ViewState[filter_name].ToString() + "') ";
        }


        return return_value;
    }

    private string CreateSql()
    {
        string sql;
        string where = "WHERE ";
        string criteria = "";



        foreach (ddlFILTER filter in Enum.GetValues(typeof(ddlFILTER)))
        {
            criteria += GetFilter(filter);
        }


        string date_range = " (CAST(ISSUE_REPORTS.CREATION_TIMESTAMP AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "') ";

        // Get radio button query type.
        if (rblType.SelectedValue == "1")
        {
            where += "ISSUE_REPORTS.CLOSED = 0 ";
        }
        else if (rblType.SelectedValue == "3")
        {
            where += "ISSUE_REPORTS.ROOT_CAUSE_CODE = '' ";
        }
        else
        {
            where += date_range  + criteria;
        }
 

        // Append the filter critera to the WHERE clause.
        where += criteria;


        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "MASTER_INDEX.FAMILY, " +
                  "MASTER_INDEX.CATEGORY, " +
                  "MASTER_INDEX.SERIAL_NUMBER, " +
                  "MASTER_INDEX.PART_NUMBER, " +
                  "ISSUE_REPORTS.PROBLEM_DESCRIPTION, " +
                  "ISSUE_REPORTS.NOTES, " +
                  "ISSUE_REPORTS.STATION_TYPE, " +
                  "ISSUE_REPORTS.NONCONFORMANCE_CODE, " +
                  "ISSUE_REPORTS.CLOSED, " +
                  "ISSUE_REPORTS.EMPLOYEE_ID, " +
                  "ISSUE_REPORTS.ISSUE_REPORTS_ID, " +
                  "ISSUE_REPORTS.CREATION_TIMESTAMP AS [ISSUE_DATE], " +
                  "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY as [NC_CATEGORY] " +
             "FROM (MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) INNER JOIN ISSUE_REPORTS_CT_NONCONFORMANCE_CODE ON ISSUE_REPORTS.NONCONFORMANCE_CODE = ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION " +
             where +
             " ORDER BY PLANT, FAMILY, CATEGORY, SERIAL_NUMBER, ISSUE_REPORTS.CREATION_TIMESTAMP";



        sql = "SELECT " +
                  "MASTER_INDEX.PLANT, " +
                  "MASTER_INDEX.FAMILY, " +
                  "MASTER_INDEX.CATEGORY, " +
                  "MASTER_INDEX.SERIAL_NUMBER, " +
                  "MASTER_INDEX.PART_NUMBER, " +
                  "ISSUE_REPORTS.PROBLEM_DESCRIPTION, " +
                  "ISSUE_REPORTS.NOTES, " +
                  "ISSUE_REPORTS.STATION_TYPE, " +
                  "ISSUE_REPORTS.NONCONFORMANCE_CODE, " +
                  "ISSUE_REPORTS.CLOSED, " +
                  "ISSUE_REPORTS.EMPLOYEE_ID, " +
                  "ISSUE_REPORTS.ISSUE_REPORTS_ID, " +
                  "ISSUE_REPORTS.CREATION_TIMESTAMP AS [ISSUE_DATE], " +
                  "ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.CATEGORY as [NC_CATEGORY], " +
                  "ISSUE_REPORTS.ASSEMBLY_STATION, " +

                  "ISSUE_REPORTS.REWORK_INSTRUCTIONS, " +
                  "ISSUE_REPORTS.ROOT_CAUSE_CODE, " +
                  "CORRECTIVE_ACTIONS.ACTION_TYPE AS [CA_ACTION_TYPE], " +
                  "CORRECTIVE_ACTIONS.NOTES AS [CA_NOTES] " +

             "FROM ( " +
                     "( MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID ) INNER JOIN ISSUE_REPORTS_CT_NONCONFORMANCE_CODE ON ISSUE_REPORTS.NONCONFORMANCE_CODE = ISSUE_REPORTS_CT_NONCONFORMANCE_CODE.DESCRIPTION " +
                   " ) LEFT JOIN CORRECTIVE_ACTIONS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = CORRECTIVE_ACTIONS.ISSUE_REPORTS_ID " +
             where +
             " ORDER BY PLANT, FAMILY, CATEGORY, SERIAL_NUMBER, ISSUE_REPORTS.CREATION_TIMESTAMP";


        //lblDebug.Text = sql;

        return sql;

    }

    private void GetIssues()
    {

        DbAccess db = new DbAccess();
        DataTable dt = new DataTable();
        string sql;

        sql = CreateSql();

        dt = db.GetData(sql);

        dt = db.GetData(sql);

        foreach (DataRow row in dt.Rows)
        {
            row["PROBLEM_DESCRIPTION"] = row["PROBLEM_DESCRIPTION"].ToString().Replace(System.Environment.NewLine, "<BR>");
            row["NOTES"] = row["NOTES"].ToString().Replace(System.Environment.NewLine, "<BR>");  
        }



        gvIssues.DataSource = dt;
        gvIssues.DataBind();

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
        ddl = (DropDownList)gvIssues.HeaderRow.FindControl(filter_name);

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


    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        ResetFilters();
        GetIssues();
    }

    public bool IsValidDate(string date)
    {

        DateTime result;    // Contains the parsed value of the string.
        bool valid_date;    // Validity state.

        // Verify that the string is formatted as a date.
        valid_date = DateTime.TryParse(date, out result);

        // Return false if the string was not a properly formatted date.
        if (!valid_date)
        {
            ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Both dates must be in mm/dd/yyyy format.');", true);
            return false;
        }

        // Valid date.
        return true;
    }


    protected void btnDownload_Click(object sender, EventArgs e)
    {

        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        DbAccess db = new DbAccess();
        DataTable dt = new DataTable();
        string sql;

        sql = CreateSql();


        dt = db.GetData(sql);

        Tools t = new Tools();
        t.CreateExcelFile("issue_reports.xls", ref dt);

    }



    protected void ddlFilter_SelectedIndexChanged(object sender, EventArgs e)
    {
        DropDownList ddlSelection = (DropDownList)sender;

        string filter_name =  ddlSelection.ID.ToString();

        ViewState[filter_name] = ddlSelection.SelectedValue;

        GetIssues();

    }

    protected void gvIssues_OnRowDataBound(object sender, GridViewRowEventArgs e)
    {
        // Create a row with 1 column for showing "Number of Records Found: "


        if (e.Row.RowType == DataControlRowType.Footer)
        {

            GridView gv1 = (GridView)sender;

            TableCell tc = new TableCell();
            tc.Text = "Number of Records Found: " + gv1.Rows.Count.ToString();
            tc.Attributes["ColSpan"] = gv1.Columns.Count.ToString();


            GridViewRow gr = new GridViewRow(-1, -1, DataControlRowType.DataRow, DataControlRowState.Normal);
            gr.Cells.Add(tc);

            Table gvTable = (Table)e.Row.Parent;
            gvTable.Controls.Add(gr);

        }


        if (e.Row.RowType == DataControlRowType.Header)
        {

            // Add space characters to allow for better readability.
            string padding = string.Join("", Enumerable.Repeat("&nbsp;", 50));
            e.Row.Cells[12].Text = padding + "PROBLEM_DESCRIPTION" + padding;
            e.Row.Cells[13].Text = padding + "NOTES" + padding;

            foreach (ListItem li in cblColumns.Items)
            {
                Int32 i = Convert.ToInt32(li.Value);

                gvIssues.Columns[i].Visible = li.Selected;

            }
        }

    }




    protected void gvIssues_RowCommand(object sender, GridViewCommandEventArgs e)
    {
        // Get the index number of the row on which the button was located.
        int index = Convert.ToInt32(e.CommandArgument);

        string value = "";

        if (e.CommandName == "View")
        {
            value = gvIssues.DataKeys[index].Values["SERIAL_NUMBER"].ToString();

            Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = value;

            Response.Redirect("Search");
        }

        if (e.CommandName == "Print")
        {
            value = gvIssues.DataKeys[index].Values["ISSUE_REPORTS_ID"].ToString();

            Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = value;

            Response.Redirect("~/Tracks/Print/PrintIssueReport.aspx");
        }


        if (e.CommandName == "Edit")
        {
            value = gvIssues.DataKeys[index].Values["ISSUE_REPORTS_ID"].ToString();

            Session[DbAccess.SessionVariableName.ISSUE_REPORT_ID.ToString()] = value;

            Response.Redirect("~/Tracks/DataEntry/IssueReports/Edit_IssueReports.aspx");
                                
        }

        if (e.CommandName == "Records")
        {
            value = gvIssues.DataKeys[index].Values["SERIAL_NUMBER"].ToString();

            Session[DbAccess.SessionVariableName.SERIAL_NUMBER.ToString()] = value;

            //string url = "http://usyouwhp6140713/Production_Queries/ypo/show_empower_test_logs.asp?SearchCriteria=" + value;
            //Response.Redirect(url);

            Response.Redirect("~/Tracks/Reports/DeviceHistory/Device_History.aspx");

        }

        if (e.CommandName == "Delete")
        {
            value = gvIssues.DataKeys[index].Values["ISSUE_REPORTS_ID"].ToString();

            IssueReports ir = new IssueReports();
            ir.Delete(value);

            GetIssues();

        }

    }

    protected void gvIssues_RowDeleting(object sender, GridViewDeleteEventArgs e)
    {
        // Needed because the word Delete is used as a command name.
    }


    protected void btnUpdateColumnSelection_Click(object sender, EventArgs e)
    {
        GetIssues();
    }
}