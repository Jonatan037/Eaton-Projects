using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Data.OleDb;

using System.Web.UI.WebControls;


namespace Tracks.DAL
{

    /// <summary>
    /// Summary description for Reports
    /// </summary>
    public class Reports
    {
        //RPO_ProdData 2
        //TPO_ProdData

        private string _connection_string = "";
        private string _results_id = "";

        private string _error_message = "";

        public string ErrorMessage
        {
            get { return _error_message; }
        }

        public Reports()
        {
            //
            // TODO: Add constructor logic here
            //
        }


        
        public bool GetReport(string DBID, string ResultsID, ref DataTable Header, ref DataTable Body)
        {
            _results_id = ResultsID;

            // Tracks
            if (DBID == "0")
            {
                return false;
            }

            // emPower
            if (DBID == "2")
            {
                _connection_string = ConfigurationManager.ConnectionStrings["RPO_ProdData_ConnectionString"].ConnectionString;
                return Get_emPower_Report(ref Header, ref Body);
            }

            // SPD
            if (DBID == "5")
            {
                _connection_string = ConfigurationManager.ConnectionStrings["SPD_ConnectionString"].ConnectionString;
                return Get_SPD_Report(ref Header, ref Body);
            }

            // emPower for Blade Bar and RPM
            if (DBID == "26")
            {
                _connection_string = ConfigurationManager.ConnectionStrings["TPO_ProdData_ConnectionString"].ConnectionString;
                return Get_emPower_Report(ref Header, ref Body);
            }

            // TDM
            if (DBID == "40")
            {
                _connection_string = ConfigurationManager.ConnectionStrings["TDMEnterpriseConnectionString"].ConnectionString;
                return Get_TDM_Report(ref Header, ref Body);
            }

            _error_message = DBID + " is not a vaild database id number";

            throw new DBAccessException(_error_message);
            //return false;
        }

        


        private bool Get_SPD_Report(ref DataTable Header, ref DataTable Body)
        {
            string sql = "";

            sql = "SELECT * FROM [Index] WHERE [ID]= " + _results_id;
            Header = GetDataFromAccessDatabase(sql);

            //sql = "SELECT * FROM Measurements WHERE [UUT_ID] = " + _results_id + "  order by [MEAS_ID]";

            sql = "SELECT P.[Parameter Name], M.[Data], M.[Low Limit],	M.[High Limit],	M.[Status] " + 
                  "FROM Measurements AS [M] INNER JOIN ParameterNames AS [P] ON M.[PARA_ID] = P.[ID] " +
                   "WHERE M.[UUT_ID] = " + _results_id + "  order by [MEAS_ID]";

            Body = GetDataFromAccessDatabase(sql);

            if ((Header.Rows.Count > 0) && (Body.Rows.Count > 0))
                return true;
            else
                return false;

        }


        private bool Get_emPower_Report(ref DataTable Header, ref DataTable Body)
        {
            int ctr = 0;
            string name = "";

            DataTable captions = GetDataFromStoredProcedure("spProgramData");

            Header = GetDataFromStoredProcedure("spTestRunInfo");

            // Remove InfoItemID fields.
            for (ctr = 1; ctr <= 10; ctr++)
                Header.Columns.Remove("Info" + ctr.ToString() + "ItemID");
                

            // Rename InfoItem fields. 
            for (ctr = 1; ctr <= 10; ctr++)
            {
                name = captions.Rows[0]["Info" + ctr.ToString() + "Name"].ToString();

                if (name != "")
                    Header.Columns["Info" + ctr.ToString() + "Item"].ColumnName = name;
            }
                

            // GetResultsData rsTestResults, lResultsID, "spTestResults"
            Body = GetDataFromStoredProcedure("spTestResults");

            if ((Header.Rows.Count > 0) && (Body.Rows.Count > 0))
                return true;
            else
                return false;
        }

        
        
        private bool Get_TDM_Report(ref DataTable Header, ref DataTable Body)
        {
            string sql = "";

            sql = "SELECT * FROM [vw_PCaT_TestResultRun_DataDog] WHERE TestRunId = " + _results_id;
            Header = GetData(sql);

            sql = "SELECT InstructionName, LowerLimit, Results, UpperLimit, Status, Units, TestComments AS [Comments] FROM [TDMEnterprise].[dbo].[vw_TDM_TEST_RESULTS] where [TestRunId] = " + _results_id + "  order by [SequenceNumber]";
            //sql = "SELECT IsNull(Results, 'NULL') AS [Results], Instruction, LSL, USL, Status, Units, Comments FROM [tbl_Result_view] where [TestRunId] = " + _results_id + "  order by [Sequence_Number]";
            Body = GetData(sql);

            if ((Header.Rows.Count > 0) && (Body.Rows.Count > 0))
                return true;
            else
                return false;
        
        }


        private DataTable GetData(string sql)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection con = new SqlConnection( _connection_string ))
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
                _error_message = ex.Message.ToString() + "  " + sql;
                throw new DBAccessException(_error_message);
            }
            return dt;

        }



        private DataTable GetDataFromAccessDatabase(string sql)
        {
            DataTable dt = new DataTable();

            try
            {
                using (OleDbConnection con = new OleDbConnection(_connection_string))
                {
                    using (OleDbCommand cmd = new OleDbCommand(sql))
                    {
                        using (OleDbDataAdapter sda = new OleDbDataAdapter())
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
                _error_message = ex.Message.ToString() + "  " + sql;
                throw new DBAccessException(_error_message);
            }
            return dt;

        }


        private DataTable GetDataFromStoredProcedure(string ProcedureName)
        {
            DataTable dt = new DataTable();

            try
            {
                using (SqlConnection connection = new SqlConnection(_connection_string))
                {

                    using (SqlDataAdapter da = new SqlDataAdapter())
                    {
                        da.SelectCommand = new SqlCommand(ProcedureName, connection);
                        da.SelectCommand.CommandType = CommandType.StoredProcedure;

                        da.SelectCommand.CommandTimeout = 60;

                        SqlParameter p = da.SelectCommand.CreateParameter();
                        p.Direction = ParameterDirection.Input;
                        p.ParameterName = "@ResultsID";
                        p.Value = _results_id;

                        da.SelectCommand.Parameters.Add(p);

                        da.Fill(dt);
                    } 
                }
            }
            catch (SqlException ex)
            {
                _error_message = ex.Message.ToString() + "  " + ProcedureName;
                throw new DBAccessException(_error_message);
            }
            return dt;

        }



        public class DBAccessException : Exception
        {
            public DBAccessException(string message)
                : base(message)
            {
            }
        }

    }



}