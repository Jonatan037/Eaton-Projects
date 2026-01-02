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


public partial class Tracks_Reports_Quality_Engineers_Get_CpK_Data : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack)
        {
            txtStartDate.Text = DateTime.Now.ToShortDateString();
            txtEndDate.Text = DateTime.Now.ToShortDateString();

        }
    }


    protected void btnFind_Click(object sender, EventArgs e)
    {
        lblDebug.Text = "";

        if (!IsValidDate(txtStartDate.Text)) return;
        if (!IsValidDate(txtEndDate.Text)) return;


        string family = RadioButtonList1.SelectedValue;

        switch (family)
        {
            case "9395": 
            case"9395P":
                Get_9395_Data(family);
            break;

            case "93PM":
            case "93PM-L":
                Get_93PM_Data(family);
            break;

            case "9355":
            case "9x55":
                Get_9355_Data(family);
            break;

            default:
                lblDebug.Text = "No family selected.";
            break;
        } 
        

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


    protected void Get_93PM_Data(string Family)
    {
        string sql = "";

        DataTable dtMeta = Get_QDMS_MetaData(Family, 40, 101);

        if (dtMeta.Rows.Count == 0)
        {
            lblDebug.Text = "No data found for " + Family + " for the specified date.";
            GridView1.DataSource = null;
            GridView1.DataBind();
            return;
        }

        var results_ids = dtMeta.AsEnumerable().Select(r => r["ResultsID"].ToString());
        string results_ids_criteria = " TestRunId IN (" + string.Join(",", results_ids) + ") ";

        //lblDebug.Text = results_ids_criteria;

        //GridView1.DataSource = dtMeta;
        //GridView1.DataBind();

        sql = "SELECT [TestRunId] AS [ResultsID], InstructionName AS [ParameterName], TestComments AS [Value] " +
              "FROM [TDMEnterprise].[dbo].[vw_TDM_TEST_RESULTS] " +
              "WHERE " + results_ids_criteria +
              "AND ( InstructionName IN( 'Verify Output Frequency L1 (BAT)', 'Verify Output Frequency L2 (BAT)', 'Verify Output Frequency L3 (BAT)', 'Verify Output Voltage' ) ) " +
              "ORDER BY [TestRunId], [SequenceNumber]";


        DataTable dtValues = Get_emPower_DataTable(sql, ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString );

        DataTable dtCombined = JoinDataTables(dtMeta, dtValues, (row1, row2) => row1.Field<int>("ResultsID") == row2.Field<int>("ResultsID"));

        DataTable dtParsed = dtCombined.Clone();

        foreach (DataRow rowCombined in dtCombined.Rows)
        {
            string parameter_name = rowCombined["ParameterName"].ToString().Trim();
            string value = rowCombined["Value"].ToString().Trim();

            int start = 0;

            if ( (parameter_name.Length > 23) && (parameter_name.Substring(0, 23) == "Verify Output Frequency") )
            {

                start = value.IndexOf("value:");
                value = value.Substring(start + 6).Trim();
                rowCombined["Value"] = value;
                dtParsed.ImportRow(rowCombined);
            }

            if (parameter_name == "Verify Output Voltage")
            {
                for (int i = 1; i <= 3; i++)
                {
                    DataRow rowParsed = dtParsed.NewRow();
                    rowParsed.ItemArray = rowCombined.ItemArray.Clone() as object[];
                    rowParsed["ParameterName"] = parameter_name + " L" + i.ToString();

                    value = value.Substring(value.IndexOf("Elem" + i.ToString() + " ") + 6).Trim();

                    if (i == 3)
                        rowParsed["Value"] = value;
                    else
                        rowParsed["Value"] = value.Substring(0, value.IndexOf(";"));

                    dtParsed.Rows.Add(rowParsed);
                }

            }        
        
        }

#if true
        Tools t = new Tools();
        t.CreateExcelFile(Family + "_CpK_Data", ref dtParsed);
#else

        GridView1.DataSource = dtParsed;
        GridView1.DataBind();
#endif

    }


    protected void Get_9355_Data(string Family)
    {
        string sql = "";

        DataTable dtMeta = Get_QDMS_MetaData(Family, 2, 2);

        if (dtMeta.Rows.Count == 0)
        {
            lblDebug.Text = "No data found for " + Family + " for the specified date.";
            GridView1.DataSource = null;
            GridView1.DataBind();
            return;
        }

        var results_ids = dtMeta.AsEnumerable().Select(r => r["ResultsID"].ToString());
        string results_ids_criteria = " ResultsID IN (" + string.Join(",", results_ids) + ") ";

        //lblDebug.Text = results_ids_criteria;

#if true
        sql = "SELECT ResultsID, LTRIM(RTRIM(tsLabel)) + ' - ' + rdLabel as [ParameterName], Actual AS [Value] " +
              "FROM tblTestStep INNER JOIN tblResultsData ON tblTestStep.TestStepID = tblResultsData.TestStepID " +
              "WHERE " + results_ids_criteria +
              " AND ( LTRIM(RTRIM(tsLabel)) IN ('Collect MSA Data') ) " +
              //" AND ( LTRIM(RTRIM(rdLabel)) IN ('Out Vrms Ph A', 'Out Vrms Ph B', 'Out Vrms Ph C', 'Output Freq Ph A', 'Output Freq Ph B', 'Output Freq Ph C') ) " +
              " ORDER BY ResultsID, ParameterName ";
#else
        sql = "SELECT ResultsID, LTRIM(RTRIM(tsLabel)) + ' - ' + rdLabel as [ParameterName], Actual AS [Value] " +
              "FROM tblTestStep INNER JOIN tblResultsData ON tblTestStep.TestStepID = tblResultsData.TestStepID " +
              "WHERE " + results_ids_criteria +
              " AND ( LTRIM(RTRIM(tsLabel)) IN ('Verify Output Freq.', 'Verify Voltage Setting') ) " +
            //" AND ( LTRIM(RTRIM(rdLabel)) IN ('Out Vrms Ph A', 'Out Vrms Ph B', 'Out Vrms Ph C', 'Output Freq Ph A', 'Output Freq Ph B', 'Output Freq Ph C') ) " +
              " ORDER BY ResultsID, ParameterName ";
#endif

        DataTable dtValues = Get_emPower_DataTable(sql, ConfigurationManager.ConnectionStrings["RPO_ProdData_ConnectionString"].ConnectionString);

        DataTable dtCombined = JoinDataTables(dtMeta, dtValues, (row1, row2) => row1.Field<int>("ResultsID") == row2.Field<int>("ResultsID"));

#if true
        Tools t = new Tools();
        t.CreateExcelFile(Family + "_CpK_Data", ref dtCombined);
#else

        GridView1.DataSource = dtParsed;
        GridView1.DataBind();
#endif

    }




    protected void Get_9395_Data(string Family)
    {
        string sql = "";

        DataTable dtMeta = Get_QDMS_MetaData(Family, 2, 2);

        if (dtMeta.Rows.Count == 0)
        {
            lblDebug.Text = "No data found for " + Family + " for the specified date.";
            GridView1.DataSource = null;
            GridView1.DataBind();
            return;
        }

        var results_ids = dtMeta.AsEnumerable().Select(r => r["ResultsID"].ToString());
        string results_ids_criteria = " ResultsID IN (" + string.Join(",", results_ids) + ") ";

        //lblDebug.Text = results_ids_criteria;


        sql = "SELECT ResultsID, LTRIM(RTRIM(tsLabel)) + ' - ' + rdLabel as [ParameterName], Actual AS [Value] " +
              "FROM tblTestStep INNER JOIN tblResultsData ON tblTestStep.TestStepID = tblResultsData.TestStepID " +
              "WHERE " + results_ids_criteria +
              " AND ( LTRIM(RTRIM(tsLabel)) IN ('Online Out Vrms Max Load', 'Online Out Freq') ) " +
              " AND ( LTRIM(RTRIM(rdLabel)) IN ('Out Vrms Ph A', 'Out Vrms Ph B', 'Out Vrms Ph C', 'Output Freq Ph A', 'Output Freq Ph B', 'Output Freq Ph C') ) " +
              "ORDER BY ResultsID, ParameterName ";

        DataTable dtValues = Get_emPower_DataTable(sql, ConfigurationManager.ConnectionStrings["RPO_ProdData_ConnectionString"].ConnectionString);

        DataTable dtCombined = JoinDataTables(dtMeta, dtValues, (row1, row2) => row1.Field<int>("ResultsID") == row2.Field<int>("ResultsID"));

#if true
        Tools t = new Tools();
        t.CreateExcelFile(Family + "_CpK_Data", ref dtCombined);
#else

        GridView1.DataSource = dtParsed;
        GridView1.DataBind();
#endif

    }



    private DataTable JoinDataTables(DataTable t1, DataTable t2, params Func<DataRow, DataRow, bool>[] joinOn)
    {
        DataTable result = new DataTable();

        foreach (DataColumn col in t1.Columns)
        {
            if (result.Columns[col.ColumnName] == null)
                result.Columns.Add(col.ColumnName, col.DataType);
        }

        foreach (DataColumn col in t2.Columns)
        {
            if (result.Columns[col.ColumnName] == null)
                result.Columns.Add(col.ColumnName, col.DataType);
        }

        foreach (DataRow row1 in t1.Rows)
        {
            var joinRows = t2.AsEnumerable().Where(row2 =>
            {
                foreach (var parameter in joinOn)
                {
                    if (!parameter(row1, row2)) return false;
                }
                return true;
            });

            foreach (DataRow fromRow in joinRows)
            {
                DataRow insertRow = result.NewRow();
                foreach (DataColumn col1 in t1.Columns)
                {
                    insertRow[col1.ColumnName] = row1[col1.ColumnName];
                }
                foreach (DataColumn col2 in t2.Columns)
                {
                    insertRow[col2.ColumnName] = fromRow[col2.ColumnName];
                }
                result.Rows.Add(insertRow);
            }
        }

        return result;
    }


    public DataTable Get_emPower_DataTable(string sql, string connection_string)
    {
        DataTable dt = new DataTable();

        //string connection_string = ConfigurationManager.ConnectionStrings["RPO_ProdData_ConnectionString"].ConnectionString;

        try
        {
            using (SqlConnection con = new SqlConnection(connection_string))
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


    protected DataTable Get_QDMS_MetaData(string Family, int DBID, int RecordType)
    {
        DbAccess dba = new DbAccess();

        string sql = "";
        string date_range = " (CAST(I.StartTime AS Date) BETWEEN '" + txtStartDate.Text.ToString() + "' AND '" + txtEndDate.Text.ToString() + "') ";


        sql = "SELECT  PN.Plant,	PN.Family, PN.Category, I.PartNumber, I.SerialNumber, StartTime, ResultsID,	PN.Description " +
              "FROM View_PowerBI_QDMS_MASTER_INDEX_WAREHOUSE_VIEW AS I LEFT JOIN PART_NUMBERS AS PN ON I.PartNumber = PN.PART_NUMBER " +
              "WHERE " + date_range + " AND I.Sequence = 1 AND  (PN.Family = '" + Family + "') AND	(I.DBID = " + DBID + ") AND results = 1 AND I.recordtype = " + RecordType  +
              " ORDER BY ResultsID ";

        
        return dba.GetData(sql);
    }

}