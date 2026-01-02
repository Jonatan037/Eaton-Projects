using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.Data;
using System.Configuration;
using System.Data.SqlClient;


namespace Tracks.DAL
{
    /// <summary>
    /// Summary description for TestCompleteReports
    /// </summary>
    public class TestCompleteReports
    {

        private string _error_message = "";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }
        }

        public TestCompleteReports()
        {
            _db = new DbAccess();
        }


        public int Add(string MasterIndexID, string SerialNumber, string PartNumber, string ProductionOrderNumber, string SalesOrderNumber, string EmployeeID, string Notes)
        {
            string sql = "";
            int return_value = 0;

            sql = "INSERT INTO TEST_COMPLETE_REPORTS " +
                  "(MASTER_INDEX_ID, SERIAL_NUMBER, PART_NUMBER, PRODUCTION_ORDER_NUMBER, SALES_ORDER_NUMBER, EMPLOYEE_ID, NOTES) " +
                  "OUTPUT Inserted.TEST_COMPLETE_REPORTS_ID " +
                  "VALUES (@MASTER_INDEX_ID, @SERIAL_NUMBER, @PART_NUMBER, @PRODUCTION_ORDER_NUMBER, @SALES_ORDER_NUMBER, @EMPLOYEE_ID, @NOTES) ";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@MASTER_INDEX_ID", MasterIndexID);
            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@PRODUCTION_ORDER_NUMBER", ProductionOrderNumber);
            command.Parameters.AddWithValue("@SALES_ORDER_NUMBER", SalesOrderNumber);
            command.Parameters.AddWithValue("@EMPLOYEE_ID", EmployeeID);
            command.Parameters.AddWithValue("@NOTES", Notes);


            // Insert new blank  report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            SetFirstTestDate(return_value);

            return return_value;
        }

        public bool Update(string TestCompleteReportID, string SerialNumber, string PartNumber, string ProductionOrderNumber, string SalesOrderNumber, string EmployeeID, string Notes)
        {
            string sql = "";
            bool return_value = false;

            sql = "UPDATE TEST_COMPLETE_REPORTS SET " +
                     "SERIAL_NUMBER = @SERIAL_NUMBER, " +
                     "PART_NUMBER = @PART_NUMBER, " +
                     "PRODUCTION_ORDER_NUMBER = @PRODUCTION_ORDER_NUMBER, " +
                     "SALES_ORDER_NUMBER = @SALES_ORDER_NUMBER, " +
                     "EMPLOYEE_ID = @EMPLOYEE_ID, " +
                     "NOTES = @NOTES " +
                  "WHERE TEST_COMPLETE_REPORTS_ID = " + TestCompleteReportID;


            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@PRODUCTION_ORDER_NUMBER", ProductionOrderNumber);
            command.Parameters.AddWithValue("@SALES_ORDER_NUMBER", SalesOrderNumber);
            command.Parameters.AddWithValue("@EMPLOYEE_ID", EmployeeID);
            command.Parameters.AddWithValue("@NOTES", Notes);


            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

        public bool Delete(string TestCompleteReportID)
        {
            string sql = "";
            bool return_value = false;

            sql = "DELETE TEST_COMPLETE_REPORTS WHERE TEST_COMPLETE_REPORTS_ID = " + TestCompleteReportID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }


        public void SetFirstTestDate(int ReportId)
        {
            string sql;
            DataTable dt;
            string master_index_id;
            string time_stamp;

            sql = "SELECT MASTER_INDEX_ID, CREATION_TIMESTAMP FROM TEST_COMPLETE_REPORTS " +
                  "WHERE TEST_COMPLETE_REPORTS_ID = " + ReportId;

            dt = _db.GetData(sql);

            master_index_id = dt.Rows[0]["MASTER_INDEX_ID"].ToString();
            time_stamp = dt.Rows[0]["CREATION_TIMESTAMP"].ToString();

            MasterIndex MI = new MasterIndex();
            MI.SetFirstTestDate(master_index_id, time_stamp, "Test Complete Report");

            MI.UpdateFlag(master_index_id, MasterIndex.FlagName.HAS_TEST_COMPLETE_REPORT, true);

            _error_message = _db.ErrorMessage;

        }

    }

}