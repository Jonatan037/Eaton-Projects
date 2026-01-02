using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;



using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.Reflection;

//using Tracks.DAL;

public partial class Tracks_Reports_Audits_LabelDatabaseTest : System.Web.UI.Page
{
    #region [TDMEnterprise].[dbo].[vw_PCaT_TestResultRun_DataDog]
    /*
    SELECT
	    [TestRunId]
	    ,[FacilityId]
	    ,[LineName]
	    ,[WorkstationName]
	    ,[ParentStationName]
	    ,[ModelNumber]
	    ,[SerialNumber]
	    ,[ShiftName]
	    ,[OperatorName]
	    ,[Passed]
	    ,[StartTime]
	    ,[StartDate]
	    ,[TestRunSpan]
	    ,[TestRunTypeID]
	    ,[TestRunType]
      FROM [TDMEnterprise].[dbo].[vw_PCaT_TestResultRun_DataDog]
    */
    #endregion


    //List<string> LineNames = new  List<string>() { "All Lines", "9395P_Line", "9395XC_Line", "93E_Line", "93PM_Line", "93PM-L_Line" };

    List<string> LineNames = new List<string>() { "All Lines", "9395P_Line", "9395XC_Line", "93E_Line", "93PM_Line", "93PM-L_Line", "SystemsTest" };

    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

            ddlLineNames.DataSource = LineNames;
            ddlLineNames.DataBind();
        }
    }


    public DataTable Get_Label_Data()
    {
        string sql;
        string _constr = ConfigurationManager.ConnectionStrings["ThreePhaseLabelConnectionString"].ConnectionString;
        DataTable dt = new DataTable();


        // Need a method of getting the most recent ID number to account for reconfigs.
        sql = "SELECT Serial AS [SerialNumber], CONFIG, ISNULL(FULLCTO, '') AS [FULLCTO], P, MODNUM, Right(Serial,10) AS [SerialNumber_R10] FROM tblArchive " +
              "ORDER BY Serial, [ID]";

#if true
        sql = "SELECT Serial AS [SerialNumber], CONFIG, ISNULL(FULLCTO, '') AS [FULLCTO], P, MODNUM, Right(Serial,10) AS [SerialNumber_R10] FROM tblArchive as [A] " +
              "WHERE [ID] = (SELECT MAX(ID) FROM tblArchive WHERE Serial = A.Serial )" +
              "ORDER BY Serial, [ID]";
#endif



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
            lblDebug.Text = ex.Message.ToString() + "  " + sql;
            //throw new DBAccessException(_error_message);
        }
        return dt;

    }



    public DataTable Get_TDM_Data()
    {
        string sql;
        string _constr = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;
        DataTable dt = new DataTable();

        //string line_names = " LineName IN ( '9395P_Line', '9395XC_Line', '93E_Line', '93PM_Line', '93PM-L_Line' ) ";

        string line_names = ddlLineNames.SelectedValue.ToString();

        if (line_names == "All Lines")
            line_names = " LineName IN ( '" + string.Join("','", LineNames.ToArray()) + "' ) ";
        else
            line_names = " LineName = '" + line_names + "' ";


        string date_range = " ( CAST(StartTime AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "' ) ";


        sql = "SELECT DISTINCT [LineName],[WorkstationName],[ParentStationName],[ModelNumber], UPPER([SerialNumber]) AS [SerialNumber] " +
              "FROM vw_PCaT_TestResultRun_DataDog " +
              "WHERE " + date_range + " AND  " + line_names +
              " ORDER BY [SerialNumber], [ModelNumber], [LineName], [ParentStationName],[WorkstationName]  ";


        lblDebug.Text = sql;

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
            lblDebug.Text = ex.Message.ToString() + "  " + sql;
            //throw new DBAccessException(_error_message);
        }
        return dt;

    }


    protected void btnSearch_Click(object sender, EventArgs e)
    {

        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;

        DataTable dtLabels = Get_Label_Data();

        DataTable dtTDM = Get_TDM_Data();



        // Need left outer join for tdm and labels.

        var list1 = from tdm in dtTDM.AsEnumerable()
                          join label in dtLabels.AsEnumerable()
                          on tdm.Field<string>("SerialNumber") equals label.Field<string>("SerialNumber_R10") into gj 
            from subset in gj.DefaultIfEmpty()
            select new
            {

                //PCaT: [LineName],[WorkstationName],[ParentStationName],[ModelNumber],[SerialNumber]
                SerialNumber = tdm.Field<string>("SerialNumber"),
                ModelNumber = tdm.Field<string>("ModelNumber"),

                LineName = tdm.Field<string>("LineName"),
                ParentStationName = tdm.Field<string>("ParentStationName"),
                WorkstationName = tdm.Field<string>("WorkstationName"),

                Label_SerialNumber = subset == null ? string.Empty : subset.Field<string>("SerialNumber"),
                Label_ConfigurationNumber = subset == null ? string.Empty : subset.Field<string>("CONFIG"),
                Label_ReferenceNumber = subset == null ? string.Empty : subset.Field<string>("FULLCTO"),
                Label_P = subset == null ? string.Empty : subset.Field<string>("P"),
                Label_MODNUM = subset == null ? string.Empty : subset.Field<string>("MODNUM"),


                Notes = string.Empty
            };


        DataTable dt = ToDataTable(list1.ToList());


        foreach (DataRow row in dt.Rows)
        {
            if ((row["Label_SerialNumber"].ToString() == "") || ( row["SerialNumber"].ToString().Length != 10 ))
            {
                row["Notes"] = "Invalid Serial Number.";
            }
            else
            {
                if ((row["ModelNumber"].ToString() != row["Label_ConfigurationNumber"].ToString()) && (row["ModelNumber"].ToString() != row["Label_ReferenceNumber"].ToString()))
                    row["Notes"] = "ModelNumber & Label_ConfigurationNumber do not match.";
            }

        }

        if ( rblDisplayMode.SelectedIndex == 0)
        {
            // Get all of the passing rows.
            DataRow[] dr = null;
            dr = dt.Select(" Notes = '' ");

            // Remove passing rows.
            foreach (DataRow row in dr)
            {
                dt.Rows.Remove(row);
            }
        }

        GridView1.DataSource = dt;
        GridView1.DataBind();


    }




    public static DataTable ToDataTable<T>(List<T> items)
    {
        DataTable dataTable = new DataTable(typeof(T).Name);

        //Get all the properties
        PropertyInfo[] Props = typeof(T).GetProperties(BindingFlags.Public | BindingFlags.Instance);
        foreach (PropertyInfo prop in Props)
        {
            //Setting column names as Property names
            dataTable.Columns.Add(prop.Name);
        }
        foreach (T item in items)
        {
            var values = new object[Props.Length];
            for (int i = 0; i < Props.Length; i++)
            {
                //inserting property values to datatable rows
                values[i] = Props[i].GetValue(item, null);
            }
            dataTable.Rows.Add(values);
        }
        //put a breakpoint here and check datatable
        return dataTable;
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


    protected void btnResetDates_Click(object sender, EventArgs e)
    {
        txtStartDate.Text = DateTime.Now.ToShortDateString();
        txtEndDate.Text = DateTime.Now.ToShortDateString();

        btnSearch_Click(sender, e);
    }

}