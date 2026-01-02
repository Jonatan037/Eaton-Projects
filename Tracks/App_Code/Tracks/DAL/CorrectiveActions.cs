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
    /// Summary description for CorrectiveActions
    /// </summary>

    public class CorrectiveActions
    {
        private string _error_message = "";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }

        }

        public CorrectiveActions()
        {
            _db = new DbAccess();
        }

        public int Add(string IssueReportID, string ActionType, string Notes)
        {
            string sql = "";
            int return_value = 0;

            sql = "INSERT INTO CORRECTIVE_ACTIONS (ISSUE_REPORTS_ID, ACTION_TYPE, NOTES) " +
                  "OUTPUT Inserted.CORRECTIVE_ACTIONS_ID " +
                  "VALUES(@ISSUE_REPORTS_ID, @ACTION_TYPE, @NOTES)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@ISSUE_REPORTS_ID", IssueReportID);
            command.Parameters.AddWithValue("@ACTION_TYPE", ActionType);
            command.Parameters.AddWithValue("@NOTES", Notes);


            // Insert new report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            return return_value;
        }

        public bool Update(string CorrectiveActionID, string ActionType, string Notes)
        {
            string sql = "";
            bool return_value = false;

            sql = "UPDATE CORRECTIVE_ACTIONS SET " +
                      "ACTION_TYPE = @ACTION_TYPE, " +
                      "NOTES = @NOTES " +
                  "WHERE CORRECTIVE_ACTIONS_ID = " + CorrectiveActionID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            command.Parameters.AddWithValue("@ACTION_TYPE", ActionType);
            command.Parameters.AddWithValue("@NOTES", Notes);

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

        public bool Delete(string CorrectiveActionID)
        {
            string sql = "";
            bool return_value = false;

            sql = "DELETE FROM CORRECTIVE_ACTIONS WHERE CORRECTIVE_ACTIONS_ID = " + CorrectiveActionID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

    }


}