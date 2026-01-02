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
    /// Summary description for LaborHours
    /// </summary>
    public class LaborHours
    {
        private string _error_message = "";
        private string _HourlyRate = "150";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }

        }


        public LaborHours()
        {
            _db = new DbAccess();
        }

        public int Add(string IssueReportID, string EmployeeID, string LaborHours, string LaborType, string Notes)
        {
            string sql = "";
            int return_value = 0;

            sql = "INSERT INTO LABOR_HOURS (ISSUE_REPORTS_ID, EMPLOYEE_ID, LABOR_HOURS, LABOR_TYPE, NOTES, HOURLY_RATE) " +
                  "OUTPUT Inserted.LABOR_HOURS_ID " +
                  "VALUES(@ISSUE_REPORTS_ID, @EMPLOYEE_ID, @LABOR_HOURS, @LABOR_TYPE, @NOTES, @HOURLY_RATE)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@ISSUE_REPORTS_ID", IssueReportID);
            command.Parameters.AddWithValue("@EMPLOYEE_ID", EmployeeID);
            command.Parameters.AddWithValue("@LABOR_HOURS", LaborHours);
            command.Parameters.AddWithValue("@LABOR_TYPE", LaborType);
            command.Parameters.AddWithValue("@NOTES", Notes);
            command.Parameters.AddWithValue("@HOURLY_RATE", _HourlyRate);

            // Insert new report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            return return_value;
        }

        public bool Update(string LaborHourID, string EmployeeID, string LaborHours, string LaborType, string Notes)
        {
            string sql = "";
            bool return_value = false;

            sql = "UPDATE LABOR_HOURS SET " +
                      "EMPLOYEE_ID = @EMPLOYEE_ID, " +
                      "LABOR_HOURS = @LABOR_HOURS, " +
                      "LABOR_TYPE = @LABOR_TYPE, " +
                      "NOTES = @NOTES " +
                      "HOURLY_RAT = @HOURLY_RAT " +
                  "WHERE LABOR_HOURS_ID = " + LaborHourID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            command.Parameters.AddWithValue("@EMPLOYEE_ID", EmployeeID);
            command.Parameters.AddWithValue("@LABOR_HOURS", LaborHours);
            command.Parameters.AddWithValue("@LABOR_TYPE", LaborType);
            command.Parameters.AddWithValue("@NOTES", Notes);
            command.Parameters.AddWithValue("@HOURLY_RATE", _HourlyRate);

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

        public bool Delete(string LaborHourID)
        {
            string sql = "";
            bool return_value = false;

            sql = "DELETE FROM LABOR_HOURS WHERE LABOR_HOURS_ID = " + LaborHourID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

    }


}