using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using System.Text;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

public partial class Tracks_Reports_TNT : System.Web.UI.Page
{

    #region [TDMEnterprise].[dbo].[tbl_Result_view]
    /*
         SELECT 
               [Catalog_Number]
              ,[Serial_Number]
              ,[TestRunId]
              ,[ResultId]
              ,[Instruction]
              ,[Test_Sequence_Name]
              ,[Start_Time]
              ,[End_Time]
              ,[Duration]
              ,[USL]
              ,[LSL]
              ,[UCL]
              ,[LCL]
              ,[Results]
              ,[Units]
              ,[Status]
              ,[PassFail]
              ,[Passed]
              ,[Comments]
              ,[Station]
              ,[Parent_Station]
              ,[Line]
              ,[Site]
              ,[Run_Type]
              ,[Run_Type_Id]
              ,[Operator]
              ,[Shift]
              ,[Sequence_Number]
              ,[Test_Sequence_Order]
              ,[FacilityId]
              ,[AssemblyLineID]
          FROM [TDMEnterprise].[dbo].[tbl_Result_view]
    */
    #endregion

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


    /// <summary>
    /// The names of the bound columns in the grids.
    /// This is also the order in which they are displayed in the grids.
    /// </summary>
    enum BColumn
    {
        TestRunId = 1,
        ResultID,
        Catalog_Number,
        Instruction,
        Results,
        Status,
        Station,
        Start_Time,
        Operator
    }

    //TestRunId	FacilityId	LineName	WorkstationName	ParentStationName	ModelNumber	SerialNumber	ShiftName	OperatorName	Passed	StartTime	StartDate	TestRunSpan	TestRunTypeID	TestRunType
    /// <summary>
    /// The names of the bound columns in the grids.
    /// This is also the order in which they are displayed in the grids.
    /// </summary>
    enum BoundColumnTestRun
    {
        TestRunId = 1,
        LineName,
        WorkstationName,
        ParentStationName,
        ModelNumber,
        SerialNumber,
        OperatorName,
        Passed,
        StartTime
    }


    /// <summary>
    /// Examples: 
    ///    SELECT ResultID, Instruction, Results, Status, Station, Parent_Station, Start_Time FROM [TDMEnterprise].[dbo].[tbl_Result_view]
    ///    SELECT * FROM [TDMEnterprise].[dbo].[tbl_Result_view] 
    ///    
    /// If any changes for column names are needed, do them in the SELECT statement.
    /// </summary>
    //const string SelectFromResultViewWhere = "SELECT * FROM [TDMEnterprise].[dbo].[tbl_Result_view] WHERE ( (Station Like '% TNT %') OR (WorkStationName Like '%CHECK%') ) AND ";
    //const string SelectFromResultViewWhere = "SELECT * FROM [TDMEnterprise].[dbo].[tbl_Result_view] WHERE ( (Station Like '% TNT %')  ) AND ";
    const string SelectFromResultViewWhere = "SELECT * FROM [TDMEnterprise].[dbo].[tbl_Result_view] WHERE ";


    protected void Page_Load(object sender, EventArgs e)
    {

        string serial_number = "";
        //string serial_number = "ER511A0005";

        // Examples for development.
        //serial_number = "EQ344A0009";
        //serial_number = "EQ285BLL01"; // Original button-up experiments.
        //serial_number = "EQ351A0002"; // unit that blew up.

        if (!IsPostBack)
        {

            if (Request.QueryString["SerialNumber"] != null)
                serial_number = Request.QueryString["SerialNumber"].ToString().Trim();


            if (serial_number != "")
            {
                TextBox1.Text = serial_number;
                Start();
            }


        }
    }


    private void Start()
    {

        string serial_number;
        string sql;


        // Set a minimum limit on the search criteria.
        if (TextBox1.Text.Trim().Length < 5)
        {
            GridView1.EmptyDataText = "Miniumn length of search criteria is 5 characters.";
            GridView1.DataSource = null;
            GridView1.DataBind();
            return;
        }


        // Reset the empty data text to default.
        GridView1.EmptyDataText = "No data found for the specified search criteria.";

        serial_number = TextBox1.Text;

        sql = "SELECT * FROM [vw_PCaT_TestResultRun_DataDog] " +
               "WHERE " + 
                  "(SerialNumber = '" + serial_number + "') "  +
                  "AND ( (WorkStationName Like '% TNT %') OR (WorkStationName Like '%CHECK%') ) " +
              "ORDER BY StartTime";


        // Add column names, ONCE, across the top of the main grid.
        if (GridView1.Columns.Count < Enum.GetValues(typeof(BoundColumnTestRun)).Length)
            AddColumnsTestRun(GridView1);

        GridView1.DataSource = GetData(sql);
        GridView1.DataBind();

        //sql = SelectFromResultViewWhere + " TestRunId = '" + test_run_id + "' order by [Sequence_Number]";
        sql = SelectFromResultViewWhere + " Serial_Number = '" + serial_number + "' order by [Sequence_Number]";

        //TestRunId	FacilityId	LineName	WorkstationName	ParentStationName	ModelNumber	SerialNumber	ShiftName	OperatorName	Passed	StartTime	StartDate	TestRunSpan	TestRunTypeID	TestRunType
        //SELECT ResultID, Instruction, Results, Status, Station, Parent_Station, Start_Time FROM [TDMEnterprise].[dbo].[tbl_Result_view]

        //sql = "SELECT TestRunId, 'TRID' + TestRunId AS [ResultId],   FROM [vw_PCaT_TestResultRun_DataDog] WHERE (SerialNumber = '" + serial_number + "') AND (WorkStationName Like '% TNT %') ORDER BY StartTime";

        //AddColumns(gvParentGrid);
        //gvParentGrid.DataSource = GetData(sql);
        //gvParentGrid.DataBind();
    }



    private DataTable GetData(string sql)
    {
        string _constr = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;


        DataTable dt = new DataTable();


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

        }
        return dt;

    }



    protected void GridViewMain_RowDataBound(object sender, GridViewRowEventArgs e)
    {
        int index_button = 0;
        int index_child_grid = e.Row.Cells.Count - 1;

        string serial_number = "";
        string test_run_id = "";
        string sql = "";

        DataTable dt;
        StringBuilder sb = new StringBuilder();


        if (e.Row.RowType == DataControlRowType.DataRow)
        {

            test_run_id = Server.HtmlDecode(e.Row.Cells[(int)BoundColumnTestRun.TestRunId].Text.Trim());
            serial_number = Server.HtmlDecode(e.Row.Cells[(int)BoundColumnTestRun.SerialNumber].Text.Trim());

            // create names for divs and images
            string div_id = "divTR" + test_run_id;
            string image_id = "img" + div_id;

            // create the link button.
            sb.Append("<a href=JavaScript:divexpandcollapse('" + div_id + "');>");
            sb.Append("<img id='" + image_id + "' width='9px' border='0' src='plus.gif' />");
            sb.Append("</a>");


            //sql = SelectFromResultViewWhere + " [Serial_Number] = '" + serial_number + "' ORDER BY Sequence_Number";
            sql = SelectFromResultViewWhere + " [TestRunId] = " + test_run_id + " ORDER BY Sequence_Number";


            // Get any data for this row.
            dt = GetData(sql);

            // Start of new row, cell and division.
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<tr><td colspan='20'>"));
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<div id='" + div_id + "' style='display: none; position: relative; left: 15px; overflow: auto; >'"));


            // Create new child grid.            
            if (dt.Rows.Count > 0)
            {
                GridView grid = new GridView();
                grid.ID = "gvChildGrid";
                grid.AutoGenerateColumns = false;

                grid.AlternatingRowStyle.BackColor = System.Drawing.Color.LightGray;
                grid.HeaderStyle.BackColor = System.Drawing.Color.Yellow;
                grid.HeaderStyle.ForeColor = System.Drawing.Color.Black;

                AddColumns(grid);

                grid.RowDataBound += new GridViewRowEventHandler(GridView_RowDataBound);
                grid.DataSource = dt;
                grid.DataBind();

                // Caption.
                Label lbl = new Label();
                lbl.Text = "<br>Showing Data For: " + serial_number;
                e.Row.Cells[index_child_grid].Controls.Add(lbl);

                // Add the child grid.
                e.Row.Cells[index_child_grid].Controls.Add(grid);
                e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<br>"));

                // Add the hyperlink button.
                e.Row.Cells[index_button].Controls.Add(new LiteralControl(sb.ToString()));
            }


            // End of new row, cell and division.
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("</td></tr>"));
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("</div>"));

        }
    }


#if true
    protected void GridView_RowDataBound(object sender, GridViewRowEventArgs e)
    {


        int index_button = 0;
        int index_child_grid = e.Row.Cells.Count - 1;

        string serial_number = "";
        string result_id = "";
        string instruction = "";
        string sql = "";

        DataTable dt;
        StringBuilder sb = new StringBuilder();



        if (e.Row.RowType == DataControlRowType.DataRow)
        {
            result_id = Server.HtmlDecode(e.Row.Cells[(int) BColumn.ResultID].Text.Trim());
            instruction = Server.HtmlDecode(e.Row.Cells[(int)BColumn.Instruction].Text.Trim());
            serial_number = Server.HtmlDecode(e.Row.Cells[(int)BColumn.Results].Text.Trim());

            // create names for divs and images
            string div_id = "div" + result_id;
            string image_id = "img" + div_id;

            // create the link button.
            sb.Append("<a href=JavaScript:divexpandcollapse('" + div_id + "');>");
            sb.Append("<img id='" + image_id + "' width='9px' border='0' src='plus.gif' />");
            sb.Append("</a>");


            sql = SelectFromResultViewWhere + " [Serial_Number] = '" + serial_number + "' ORDER BY Sequence_Number";


            // Get any data for this row.
            dt = GetData(sql);

            // Start of new row, cell and division.
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<tr><td colspan='20'>"));
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<div id='" + div_id + "' style='display: none; position: relative; left: 15px; overflow: auto; >'"));


            // Create new child grid.            
            if (dt.Rows.Count > 0)
            {
                GridView grid = new GridView();
                grid.ID = "gvChildGrid";
                grid.AutoGenerateColumns = false;

                grid.RowDataBound += new GridViewRowEventHandler(GridView_RowDataBound); 

                grid.AlternatingRowStyle.BackColor = System.Drawing.Color.LightGray;
                grid.HeaderStyle.BackColor = System.Drawing.Color.Yellow;
                grid.HeaderStyle.ForeColor = System.Drawing.Color.Black;
               
                AddColumns(grid);

                grid.DataSource = dt;
                grid.DataBind();

                // Caption.
                Label lbl = new Label();
                lbl.Text = "<br>Showing Data For: " + serial_number + " - " + instruction + " - " + dt.Rows[0]["Station"].ToString();
                e.Row.Cells[index_child_grid].Controls.Add(lbl);

                // Add the child grid.
                e.Row.Cells[index_child_grid].Controls.Add(grid);
                e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("<br>"));

                // Add the hyperlink button.
                e.Row.Cells[index_button].Controls.Add(new LiteralControl(sb.ToString()));
            }


            // End of new row, cell and division.
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("</td></tr>"));
            e.Row.Cells[index_child_grid].Controls.Add(new LiteralControl("</div>"));

        }
    }
#endif


    private void AddColumns(GridView TargetGrid)
    {
        // Add the column for the hyperlink.
        TemplateField tfield = new TemplateField();
        //tfield.HeaderText = "button";
        tfield.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(20);
        TargetGrid.Columns.Add(tfield);

        // Add each of the bound data columns to the grid.
        foreach (string name in Enum.GetNames(typeof(BColumn)))
        {
            BoundField bfield = new BoundField();

            bfield.DataField = name;

            if (name == "Results")
                bfield.HeaderText = name + "/SerialNumber";
            else
                bfield.HeaderText = name;


            TargetGrid.Columns.Add(bfield);
        }

        // Add the column for the child grid.
        tfield = new TemplateField();
        //tfield.HeaderText = "Child Grid";
        TargetGrid.Columns.Add(tfield);
    }

    private void AddColumnsTestRun(GridView TargetGrid)
    {

        // Add the column for the hyperlink.
        TemplateField tfield = new TemplateField();
        //tfield.HeaderText = "button";
        tfield.ItemStyle.Width = System.Web.UI.WebControls.Unit.Pixel(20);
        TargetGrid.Columns.Add(tfield);

        // Add each of the bound data columns to the grid.
        foreach (string name in Enum.GetNames(typeof(BoundColumnTestRun)))
        {
            BoundField bfield = new BoundField();

            bfield.DataField = name;
            bfield.HeaderText = name;
            TargetGrid.Columns.Add(bfield);
        }


        // Add the column for the child grid.
        tfield = new TemplateField();
        //tfield.HeaderText = "Child Grid";
        TargetGrid.Columns.Add(tfield);
    }



    protected void btnSearch_Click(object sender, EventArgs e)
    {
        Start();
    }
}