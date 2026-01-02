using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Data;
using System.Configuration;
using System.Data.SqlClient;

//using System.Web.UI;
using System.Web.UI.WebControls;

namespace Tracks.DAL
{ 
    public class DbAccess
    {

        private string _constr = ConfigurationManager.ConnectionStrings["NCRConnectionString"].ConnectionString;

        private string _error_message = "";

        public string ErrorMessage
        {
            get { return _error_message; }
        }

        public enum SessionVariableName
        {
            BUILD_REPORT_ID ,         
            COMPONENT_ID,
            CORRECTIVE_ACTION_ID,
        
            FILE_ID,

            ISSUE_REPORT_ID,
            ISSUE_REPORT_PANEL_STATE,

            LABOR_HOUR_ID,
            MASTER_INDEX_ID,
            SERIAL_NUMBER,
            TEST_COMPLETE_REPORT_ID,

            REPORT_DBID,                // Used in showing reports from TDM or QDMS
            REPORT_RESULTS_ID           // Used in showing reports from TDM or QDMS
        }

        public enum DropListType
        {
            COMPONENTS_CT_DISPOSITION_TYPE,
            COMPONENTS_CT_REPLACEMENT_REASON_TYPE,

            CORRECTIVE_ACTIONS_CT_ACTION_TYPE,
            
            ISSUE_REPORTS_CT_NONCONFORMANCE_CODE,
            ISSUE_REPORTS_CT_NONCONFORMANCE_CATEGORY,
            ISSUE_REPORTS_CT_ROOT_CAUSE_CODE,
            ISSUE_REPORTS_CT_STATION_TYPE,
            ISSUE_REPORTS_CT_STATUS,

            LABOR_HOURS_CT_LABOR_TYPE,

        }


        public DbAccess()
        {
        }


        public string ExecuteNonQuery(SqlCommand command)
        {
            // Reset error message.
            _error_message = "";

            using (SqlConnection conn = new SqlConnection(_constr))
            {
                //using (SqlCommand command)
                {
                    command.Connection = conn;

                    try
                    {
                        conn.Open();
                        command.ExecuteNonQuery();
                    }
                    catch (SqlException ex)
                    {
                        _error_message = ex.Message.ToString()  + "<br />" + command.CommandText;
                    }
                }
            }

            return _error_message;
        }


        public int ExecuteScalar(SqlCommand command)
        {
            // Reset error message.
            _error_message = "";

            object value = null;

            using (SqlConnection conn = new SqlConnection(_constr))
            {
                //using (SqlCommand command)
                {
                    command.Connection = conn;

                    try
                    {
                        conn.Open();
                        //return_value = (int) command.ExecuteScalar();
                        value = command.ExecuteScalar();
                    }
                    catch (SqlException ex)
                    {
                        _error_message = ex.Message.ToString() + "<br />" + command.CommandText;
                    }
                }
            }

            // Return 0 if no results were returned.
            if (value == null) return 0;

            // Handle true and false cases.
            if (value.ToString() == "True") return 1;
            if (value.ToString() == "False") return 0;

            // return integer value
            return int.Parse(value.ToString());

        }

        public void PopulateDropDownList(DropDownList ddl, DropListType dlt)
        {
            string sql;
            //string sql = "SELECT [ID], [DESCRIPTION] FROM " + dlt.ToString();
            //string sql = "SELECT [ID], IIF(IsNull([DESCRIPTION]), ID), DESCRIPTION) AS [DESCRIPTION] FROM " + dlt.ToString();
            //string sql = "SELECT [ID], (ID + ': ' + [DESCRIPTION]) AS [DESCRIPTION] FROM " + dlt.ToString();

            if (dlt == DropListType.ISSUE_REPORTS_CT_NONCONFORMANCE_CODE)
            {
                //sql = "SELECT [ID], (ID + ': ' + [DESCRIPTION]) AS [DESCRIPTION] FROM ISSUE_REPORTS_CT_NONCONFORMANCE_CODE WHERE ACTIVE = 1 ORDER BY ID";
                sql = "SELECT [DESCRIPTION] AS [ID], [DESCRIPTION] FROM ISSUE_REPORTS_CT_NONCONFORMANCE_CODE WHERE ACTIVE = 1 ORDER BY [DESCRIPTION]";
            }

            else if (dlt == DropListType.ISSUE_REPORTS_CT_NONCONFORMANCE_CATEGORY)
            {
                sql = "SELECT [CATEGORY] AS [ID], [CATEGORY] AS [DESCRIPTION] FROM ISSUE_REPORTS_CT_NONCONFORMANCE_CODE GROUP BY [CATEGORY] ORDER BY [CATEGORY]";
            }

            else if (dlt == DropListType.COMPONENTS_CT_DISPOSITION_TYPE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM COMPONENTS_CT_DISPOSITION_TYPE ORDER BY ID";
            }

            else if (dlt == DropListType.COMPONENTS_CT_REPLACEMENT_REASON_TYPE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM COMPONENTS_CT_REPLACEMENT_REASON_TYPE ORDER BY ID";
            }
            else if (dlt == DropListType.LABOR_HOURS_CT_LABOR_TYPE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM LABOR_HOURS_CT_LABOR_TYPE ORDER BY ID";
            }
            else if (dlt == DropListType.CORRECTIVE_ACTIONS_CT_ACTION_TYPE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM CORRECTIVE_ACTIONS_CT_ACTION_TYPE ORDER BY ID";
            }
            else if (dlt == DropListType.ISSUE_REPORTS_CT_STATION_TYPE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM ISSUE_REPORTS_CT_STATION_TYPE ORDER BY ID";
            }
            else if (dlt == DropListType.ISSUE_REPORTS_CT_STATUS)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM ISSUE_REPORTS_CT_STATUS WHERE ACTIVE = 1 ORDER BY ID";
            }
            else if (dlt == DropListType.ISSUE_REPORTS_CT_ROOT_CAUSE_CODE)
            {
                sql = "SELECT [ID], ID AS [DESCRIPTION] FROM ISSUE_REPORTS_CT_ROOT_CAUSE_CODE ORDER BY ID";
            }
            else
            {
                sql = "SELECT [ID], [DESCRIPTION] FROM " + dlt.ToString();
            }

            DataTable dt = GetData(sql);

            ddl.DataSource = dt;

            ddl.DataTextField = "DESCRIPTION";
            //ddl.DataTextField = "ID";

            ddl.DataValueField = "ID";

            ddl.DataBind();
        }

        public void DropDownList_SelectedValue(DropDownList ddl, string value)
        {
            // If the specified value is not in the list, then add it.
            if (ddl.Items.FindByValue(value) == null)
                ddl.Items.Add(ListItem.FromString(value));

            // Select the specified value.
            ddl.SelectedValue = value; ;
        }



        public DataTable GetData(string sql)
        {
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
                _error_message = ex.Message.ToString() + "  " + sql;
                throw new DBAccessException(_error_message);
            }
                return dt;

        }


        public class DBAccessException : Exception
        {
            public DBAccessException(string message) : base(message)
            {
            }
        }


    }

}