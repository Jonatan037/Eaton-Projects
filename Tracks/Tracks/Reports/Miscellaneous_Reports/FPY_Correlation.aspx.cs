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

public partial class Tracks_Reports_Miscellaneous_Reports_FPY_Correlation : System.Web.UI.Page
{


    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = txtStartDate.Text;

        }
    }



    private DataTable GetFPYData()
    {
        string _constr = ConfigurationManager.ConnectionStrings["QDMS_YPO_TEST"].ConnectionString;
        
        DataTable dt = new DataTable();

        DateTime start_date = DateTime.Parse(txtStartDate.Text);
        DateTime end_date = DateTime.Parse(txtEndDate.Text);
        end_date = end_date.AddDays(1);


        try
        {
            using (SqlConnection con = new SqlConnection(_constr))
            {
                using (SqlCommand cmd = new SqlCommand("spGetYields"))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.CommandTimeout = 60;

                    cmd.Parameters.Add("@StartDate", SqlDbType.DateTime).Value = start_date;
                    cmd.Parameters.Add("@EndDate", SqlDbType.DateTime).Value = end_date;

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
            lblDebug.Text = ex.Message.ToString();
        }



        if (dt.Rows.Count == 0) return dt;

        // ----------------------------------------------------------------------------------------------------
        // Get just failed records for the specified palnt.

        DataView view = dt.DefaultView;

        view.Sort = "SerialNumber";
        view.RowFilter = "TestResult = 'Fail' AND Plant = '" + ddlPlants.SelectedItem.ToString() + "'";
        DataTable newTable = view.ToTable();

        return newTable;

    }


    protected void btnFind_Click(object sender, EventArgs e)
    {
        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        DataTable dt;

        dt = GetFPYData();

        GridView1.DataSource = dt;
        GridView1.DataBind();

        //-----------------------------------------------------------------------------------------------------
        // Get the issue reports for these units.
        string serial_number_criteria = "";

        foreach (DataRow row in dt.Rows)
        {
            if (serial_number_criteria == "")
                serial_number_criteria = "'" + row["SerialNumber"].ToString() + "'";
            else
                serial_number_criteria += ", '" + row["SerialNumber"].ToString() + "'";
        }

        if (serial_number_criteria == "") serial_number_criteria = "''";

        serial_number_criteria = " (" + serial_number_criteria + ") ";

        string sql;

        sql = "SELECT " +
              "MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, MASTER_INDEX.CATEGORY, MASTER_INDEX.SERIAL_NUMBER, MASTER_INDEX.PART_NUMBER, ISSUE_REPORTS.* " +
              "FROM MASTER_INDEX LEFT JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID " +
              "WHERE MASTER_INDEX.SERIAL_NUMBER IN " + serial_number_criteria +
              "ORDER BY MASTER_INDEX.SERIAL_NUMBER, ISSUE_REPORTS.CREATION_TIMESTAMP";


        //lblDebug.Text = sql;


        DbAccess DB = new DbAccess();
        dt = DB.GetData(sql);

        //lblDebug.Text = DB.ErrorMessage;

        gvIssueReports.DataSource = dt;
        gvIssueReports.DataBind();


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

    protected void btnReset_Click(object sender, EventArgs e)
    {

    }
}