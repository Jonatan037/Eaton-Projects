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
    /// Summary description for Reports
    /// </summary>
    public class IssueReports
    {

        private string _error_message = "";
        private DbAccess _db;


        public string ErrorMessage
        {
            get { return _error_message; }

        }

        public IssueReports()
        {
            _db = new DbAccess();
        }


        public int Add(string MasterIndexID, string EmployeeID, string ProblemDescription = "", bool FirstTestDateFlag = true, string TimeStamp = "")
        {
            string sql = "";
            int return_value = 0;

            if (TimeStamp == "") TimeStamp = DateTime.Now.ToString();

            sql = "INSERT INTO ISSUE_REPORTS (MASTER_INDEX_ID, EMPLOYEE_ID, PROBLEM_DESCRIPTION, CREATION_TIMESTAMP) " +
                  "OUTPUT Inserted.ISSUE_REPORTS_ID " +
                  "VALUES(@MASTER_INDEX_ID, @EMPLOYEE_ID, @PROBLEM_DESCRIPTION, @CREATION_TIMESTAMP)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@MASTER_INDEX_ID", MasterIndexID);
            command.Parameters.AddWithValue("@EMPLOYEE_ID", EmployeeID);
            command.Parameters.AddWithValue("@PROBLEM_DESCRIPTION", ProblemDescription);
            command.Parameters.AddWithValue("@CREATION_TIMESTAMP", TimeStamp);

            // Insert new blank  report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            MasterIndex MI = new MasterIndex();

            // Set the HAS_ISSUE_REPORT flag to true.
            MI.UpdateFlag(MasterIndexID, MasterIndex.FlagName.HAS_ISSUE_REPORT, true);

            // Set the FAILED flag to true.
            MI.UpdateFlag(MasterIndexID, MasterIndex.FlagName.FAILED, true);

            // Update the master index first test date field.
            if (FirstTestDateFlag)
                SetFirstTestDate(return_value);

            return return_value;
        }

        public bool Update(string IssueReportsID, string ProblemDescription, string Notes, string ReworkInstructions, string NonconformanceCode, string StationType, string RootCauseCode, string Status, bool Closed, string AssemblyStation, string Builder, string Verifier, bool Locked = false)
        {
            string sql = "";
            bool return_value = false;

            // If this issue is being closed, then set the status to closed.
            if (Closed == true) Status = "Closed";

            sql = "UPDATE ISSUE_REPORTS SET " +
                      "PROBLEM_DESCRIPTION= @PROBLEM_DESCRIPTION, " +
                      "NOTES = @NOTES, " +
                      "REWORK_INSTRUCTIONS = @REWORK_INSTRUCTIONS, " +
                      "NONCONFORMANCE_CODE = @NONCONFORMANCE_CODE, " +
                      "STATION_TYPE = @STATION_TYPE, " +
                      "ROOT_CAUSE_CODE= @ROOT_CAUSE_CODE, " +
                      "STATUS = @STATUS, " +
                      "CLOSED = @CLOSED, " +
                      "ASSEMBLY_STATION = @ASSEMBLY_STATION, " +
                      "BUILDER = @BUILDER, " +
                      "VERIFIER = @VERIFIER, " +
                      "LOCKED = @LOCKED " +
                  "WHERE ISSUE_REPORTS_ID = " + IssueReportsID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            command.Parameters.AddWithValue("@PROBLEM_DESCRIPTION", ProblemDescription);
            command.Parameters.AddWithValue("@NOTES", Notes);
            command.Parameters.AddWithValue("@REWORK_INSTRUCTIONS", ReworkInstructions);
            command.Parameters.AddWithValue("@NONCONFORMANCE_CODE", NonconformanceCode);
            command.Parameters.AddWithValue("@STATION_TYPE", StationType);
            command.Parameters.AddWithValue("@ROOT_CAUSE_CODE", RootCauseCode);
            command.Parameters.AddWithValue("@STATUS", Status);
            command.Parameters.AddWithValue("@CLOSED", Closed);
            command.Parameters.AddWithValue("@ASSEMBLY_STATION", AssemblyStation);
            command.Parameters.AddWithValue("@BUILDER", Builder);
            command.Parameters.AddWithValue("@VERIFIER", Verifier);
            command.Parameters.AddWithValue("@LOCKED", Locked);

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }

        public bool Delete(string IssueReportID)
        {
            string sql = "";
            bool return_value = false;
            string master_index_id = "";
            string serial_number = "";
            int issue_report_count = 0;

            // Get the master index id for this issue report.
            GetMasterIndexInfo(IssueReportID, ref master_index_id, ref serial_number);

            // ---------------------------------------------------------------------------------
            sql = "DELETE FROM ISSUE_REPORTS WHERE ISSUE_REPORTS_ID = " + IssueReportID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;


            // ---------------------------------------------------------------------------------
            // Get the number of issue report that remain for this unit.
            command.CommandText = "SELECT COUNT(MASTER_INDEX_ID) FROM ISSUE_REPORTS WHERE MASTER_INDEX_ID = " + master_index_id;
            issue_report_count = _db.ExecuteScalar(command);

            // If there are not any more issue reports for this unit, then reset the flags.
            if (issue_report_count == 0)
            {
                command.CommandText = "UPDATE MASTER_INDEX SET HAS_ISSUE_REPORT = 0, FAILED = 0, HAS_ATE_FAILURE_REPORT = 0 WHERE MASTER_INDEX_ID = " + master_index_id;

                _error_message = _db.ExecuteNonQuery(command);

                if (_error_message == "")
                    return_value = true;
                else 
                    return_value = false;
            }

            return return_value;
        }

#if false
        public bool Delete(string IssueReportID)
        {
            string sql = "";
            bool return_value = false;

            sql = "DELETE FROM ISSUE_REPORTS WHERE ISSUE_REPORTS_ID = " + IssueReportID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }
#endif


        public void SetFirstTestDate(int IssueReportId)
        {
            string sql;
            DataTable dt;
            string master_index_id;
            string time_stamp;

            sql = "SELECT MASTER_INDEX_ID, CREATION_TIMESTAMP FROM ISSUE_REPORTS " +
                  "WHERE ISSUE_REPORTS_ID = " + IssueReportId;

            dt = _db.GetData(sql);

            master_index_id = dt.Rows[0]["MASTER_INDEX_ID"].ToString();
            time_stamp = dt.Rows[0]["CREATION_TIMESTAMP"].ToString();

            MasterIndex MI = new MasterIndex();
            MI.SetFirstTestDate(master_index_id, time_stamp, "Issue Report");

            //MI.UpdateFlag(master_index_id, "HAS_ISSUE_REPORT");

            _error_message = _db.ErrorMessage;

        }

        public void GetMasterIndexInfo(string IssueReportID, ref string MasterIndexID, ref string SerialNumber)
        {
            string sql;
            DataTable dt;

            // Defaults
            MasterIndexID = "";
            SerialNumber = "";

            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, SERIAL_NUMBER " +
                  "FROM ISSUE_REPORTS INNER JOIN MASTER_INDEX ON ISSUE_REPORTS.MASTER_INDEX_ID = MASTER_INDEX.MASTER_INDEX_ID " +
                  "WHERE ISSUE_REPORTS_ID = " + IssueReportID;

            dt = _db.GetData(sql);

            MasterIndexID = dt.Rows[0]["MASTER_INDEX_ID"].ToString();

            SerialNumber = dt.Rows[0]["SERIAL_NUMBER"].ToString();
        }


        public void GetMasterIndexInfo(string IssueReportID, ref string MasterIndexID, ref string SerialNumber, ref string Plant, ref string Family, ref string Category)
        {
            string sql;
            DataTable dt;

            // Defaults
            MasterIndexID = "";
            SerialNumber = "";
            Plant = "";
            Family = "";
            Category = "";

            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, MASTER_INDEX.PLANT, MASTER_INDEX.FAMILY, MASTER_INDEX.Category, MASTER_INDEX.SERIAL_NUMBER " +
                  "FROM ISSUE_REPORTS INNER JOIN MASTER_INDEX ON ISSUE_REPORTS.MASTER_INDEX_ID = MASTER_INDEX.MASTER_INDEX_ID " +
                  "WHERE ISSUE_REPORTS_ID = " + IssueReportID;

            dt = _db.GetData(sql);

            MasterIndexID = dt.Rows[0]["MASTER_INDEX_ID"].ToString();

            SerialNumber = dt.Rows[0]["SERIAL_NUMBER"].ToString();

            Plant = dt.Rows[0]["PLANT"].ToString();
            Family = dt.Rows[0]["FAMILY"].ToString();
            Category = dt.Rows[0]["Category"].ToString();
        }
    }
}