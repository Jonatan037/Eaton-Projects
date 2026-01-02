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

public partial class Tracks_Reports_Miscellaneous_Reports_Component_Search : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }


    private DataTable GetData()
    {
        string sql = "";
        string criteria = "";

        DbAccess db = new DbAccess();

        criteria = " '" + txtSearch.Text + "%' ";


        sql = "SELECT " +
                 "[MASTER_INDEX].PART_NUMBER AS [UNIT_PART_NUMBER], [MASTER_INDEX].SERIAL_NUMBER AS [UNIT_SERIAL_NUMBER], " +
                 "COMPONENTS.PART_NUMBER AS [COMPONENT_PART_NUMBER], COMPONENTS.SERIAL_NUMBER  AS [COMPONENT_SERIAL_NUMBER], " +
                 "ISSUE_REPORTS.CREATION_TIMESTAMP, ISSUE_REPORTS.STATION_TYPE, ISSUE_REPORTS.PROBLEM_DESCRIPTION, ISSUE_REPORTS.NOTES " +
              "FROM " +
                 "( MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID ) " +
                 "LEFT JOIN COMPONENTS ON ISSUE_REPORTS.ISSUE_REPORTS_ID = COMPONENTS.ISSUE_REPORTS_ID " +
              "WHERE (MASTER_INDEX.PART_NUMBER LIKE " + criteria + ") OR (COMPONENTS.[PART_NUMBER] LIKE " + criteria + ") " +
              "ORDER BY MASTER_INDEX.PART_NUMBER, MASTER_INDEX.SERIAL_NUMBER ";


        lblTitle.Text = "Component part numbers starting with " + txtSearch.Text;

     
        lblDebug.Text = sql;

        return db.GetData(sql);

    }



    protected void btnSearch_Click(object sender, EventArgs e)
    {

        if (txtSearch.Text == "") return;

        gvComponents.DataSource = GetData();
        gvComponents.DataBind();
    }


    protected void btnDownload_Click(object sender, EventArgs e)
    {
        if (txtSearch.Text == "") return;


        string filename = "Components";
        DataTable dt = GetData();

        Tools t = new Tools();
        t.CreateExcelFile(filename, ref dt);

    }
}