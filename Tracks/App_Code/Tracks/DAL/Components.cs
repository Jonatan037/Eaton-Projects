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
    /// Summary description for Components
    /// </summary>
    public class Components
    {
        private string _error_message = "";
        private DbAccess _db;
        

        public string ErrorMessage
        {
            get { return _error_message; }

        }

        public Components()
        {
            _db = new DbAccess();
        }

        public int Add(string IssueReportID, string SerialNumber, string PartNumber, string ReplacementReasonType, string DispositionType, string Notes)
        {
            string sql = "";
            int return_value = 0;

            sql = "INSERT INTO COMPONENTS (ISSUE_REPORTS_ID, SERIAL_NUMBER, PART_NUMBER, REPLACEMENT_REASON_TYPE, DISPOSITION_TYPE, NOTES) " +
                  "OUTPUT Inserted.COMPONENTS_ID " +
                  "VALUES(@ISSUE_REPORTS_ID, @SERIAL_NUMBER, @PART_NUMBER, @REPLACEMENT_REASON_TYPE, @DISPOSITION_TYPE, @NOTES)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@ISSUE_REPORTS_ID", IssueReportID);
            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@REPLACEMENT_REASON_TYPE", ReplacementReasonType);
            command.Parameters.AddWithValue("@DISPOSITION_TYPE", DispositionType);
            command.Parameters.AddWithValue("@NOTES", Notes);


            // Insert new report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            UpdateMetaData(return_value.ToString());

            return return_value;
        }

        public bool Update(string ComponentID, string SerialNumber, string PartNumber, string ReplacementReasonType, string DispositionType, string Notes)
        {
            string sql = "";
            bool return_value = false;

            sql = "UPDATE COMPONENTS SET " +
                      "SERIAL_NUMBER = @SERIAL_NUMBER, " +
                      "PART_NUMBER = @PART_NUMBER, " +
                      "REPLACEMENT_REASON_TYPE = @REPLACEMENT_REASON_TYPE, " +
                      "DISPOSITION_TYPE = @DISPOSITION_TYPE, " +
                      "NOTES = @NOTES " +
                  "WHERE COMPONENTS_ID = " + ComponentID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@REPLACEMENT_REASON_TYPE", ReplacementReasonType);
            command.Parameters.AddWithValue("@DISPOSITION_TYPE", DispositionType);
            command.Parameters.AddWithValue("@NOTES", Notes);

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            UpdateMetaData(ComponentID);

            return return_value;
        }

        public bool Delete(string ComponentID)
        {
            string sql = "";
            bool return_value = false;

            sql = "DELETE FROM COMPONENTS WHERE COMPONENTS_ID = " + ComponentID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

        public void UpdateMetaData(string ComponentID = "")
        {
            string sql;
            string criteria = "";

            // Create the criteria if a component id was include as a parameter.
            if (ComponentID != "")
                criteria = " WHERE COMPONENTS_ID = '" + ComponentID + "'";

            sql = "UPDATE COMPONENTS " +
                  "SET " +
                     "COMPONENTS.COST = [PART_NUMBERS].[COST], " +
                     "COMPONENTS.DESCRIPTION = [PART_NUMBERS].[DESCRIPTION] " +
                  "FROM COMPONENTS INNER JOIN PART_NUMBERS ON COMPONENTS.PART_NUMBER = PART_NUMBERS.PART_NUMBER " +
                  criteria;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

        }

        public string GetList(string IssueReportId)
        {
            string results = "";
            string sql;
            DataTable dt;

            sql = "SELECT PART_NUMBER FROM COMPONENTS WHERE ISSUE_REPORTS_ID = " + IssueReportId;

            dt = _db.GetData(sql);

            foreach(DataRow row in dt.Rows)
            {
                results += row[0].ToString() + "<br>";
            }

            return results;
        }
    }

}

