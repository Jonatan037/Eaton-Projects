using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.Data;
using System.Configuration;
using System.Data.SqlClient;

using System.Runtime.InteropServices;

using System.Web.UI.WebControls;
using System.Text;

namespace Tracks.DAL
{
    /// <summary>
    /// Summary description for Files
    /// </summary>
    public class FileStorage
    {
        private string _physical_path = "C:\\_WebAppFileStorage\\Tracks\\";
        private string _virtual_path = "~/FileStorage/";

        private string _error_message = "";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }
        }

        public FileStorage()
        {
            _db = new DbAccess();
        }



        // Upload a file from the client to the server.
        public string UploadFile(FileUpload Upload, string IssueReportID, string Notes)
        {

            StringBuilder sb = new StringBuilder();            
            
            string original_filename;
            string saved_as_filename;

            original_filename = Upload.FileName;

            saved_as_filename = CreatGUID() + "_" + original_filename;

            _error_message = "";


            if (Upload.HasFile)
            {
                try
                {
                    sb.AppendFormat(" Uploading file: {0}", saved_as_filename);

                    //saving the file
                    Upload.SaveAs(_physical_path + saved_as_filename);

                    //Showing the file information
                    sb.AppendFormat("<br/> Save As: {0}", Upload.PostedFile.FileName);
                    sb.AppendFormat("<br/> File type: {0}", Upload.PostedFile.ContentType);
                    sb.AppendFormat("<br/> File length: {0}", Upload.PostedFile.ContentLength);
                    sb.AppendFormat("<br/> File name: {0}", Upload.PostedFile.FileName);

                }
                catch (Exception ex)
                {
                    sb.Append("<br/> Error <br/>");
                    sb.AppendFormat("Unable to save file <br/> {0}", ex.Message);
                    _error_message = sb.ToString();
                    return _error_message;
                }
            }

            Add(IssueReportID, original_filename, saved_as_filename, Notes);

            // return url
            return _virtual_path + saved_as_filename; ; 


        }

        // Download a file to from the server to the client.
        public string DownloadFile()
        {
            return "";
        }


        public DataTable GetData(string IssueReportID)
        {
            string sql;

            sql = "SELECT *, '" + _virtual_path + "' + SAVED_AS_FILENAME AS [FILE_PATH] " +
                  "FROM [FILE_STORAGE] WHERE [ISSUE_REPORTS_ID] = " + IssueReportID + 
                  " ORDER BY FILE_STORAGE_ID";

            return _db.GetData(sql);

        }


        public string GetSQL(string MasterIndexid)
        {
            string sql;

            sql = "SELECT MASTER_INDEX.MASTER_INDEX_ID, FILE_STORAGE.*, '" + _virtual_path + "' + SAVED_AS_FILENAME AS [FILE_PATH] " +
                    "FROM(MASTER_INDEX INNER JOIN ISSUE_REPORTS ON MASTER_INDEX.MASTER_INDEX_ID = ISSUE_REPORTS.MASTER_INDEX_ID) " +
                    "INNER JOIN FILE_STORAGE ON ISSUE_REPORTS.ISSUE_REPORTS_ID = FILE_STORAGE.ISSUE_REPORTS_ID " +
                    "WHERE MASTER_INDEX.MASTER_INDEX_ID = " + MasterIndexid +
                    " ORDER BY FILE_STORAGE_ID";

            return sql;
        }

        public bool Update(string FileID, string Notes)
        {
            string sql = "";
            bool return_value = false;

            sql = "UPDATE FILE_STORAGE " +
                  "SET NOTES = @NOTES " +
                  "WHERE FILE_STORAGE_ID = " + FileID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            command.Parameters.AddWithValue("@NOTES", Notes);

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }


        public bool Delete(string FileID)
        {
            string filename;
            string sql = "";
            bool return_value = false;

            // ----------------------------------------------------------------------------------
            // Delete the file from the directory.

            filename = GetPhysicalPath(FileID);

            if (filename != "")
            {
                if ((System.IO.File.Exists(filename)))
                {
                    System.IO.File.Delete(filename);
                }

            }

            // ----------------------------------------------------------------------------------
            // Delete the entry from the database.

            sql = "DELETE FROM FILE_STORAGE WHERE FILE_STORAGE_ID = " + FileID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            if (_error_message == "") return_value = true;

            return return_value;
        }



        private int Add(string IssueReportID, string OriginalFileName, string SaveAsFileName, string Notes)
        {
            string sql = "";
            int return_value = 0;

            sql = "INSERT INTO FILE_STORAGE(ISSUE_REPORTS_ID, ORIGINAL_FILENAME, SAVED_AS_FILENAME, UPLOADED_TIMESTAMP, NOTES) " +
                  "OUTPUT Inserted.FILE_STORAGE_ID " +
                  "VALUES(@ISSUE_REPORTS_ID, @ORIGINAL_FILENAME, @SAVED_AS_FILENAME, @UPLOADED_TIMESTAMP, @NOTES)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@ISSUE_REPORTS_ID", IssueReportID);
            command.Parameters.AddWithValue("@ORIGINAL_FILENAME", OriginalFileName);
            command.Parameters.AddWithValue("@SAVED_AS_FILENAME", SaveAsFileName);
             command.Parameters.AddWithValue("@UPLOADED_TIMESTAMP", DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss") );
            command.Parameters.AddWithValue("@NOTES", Notes);


            // Insert new report and get its ID.
            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            return return_value;
        }


        private string GetPhysicalPath(string FileID)
        {
            DataTable dt;
            string sql;

            sql = "SELECT * FROM FILE_STORAGE WHERE FILE_STORAGE_ID = " + FileID;

            dt = _db.GetData(sql);

            if (dt.Rows.Count > 0)
            {
                return _physical_path + dt.Rows[0]["SAVED_AS_FILENAME"].ToString();
            }
            else
            {
                return "";
            }
            
        }

        private string CreatGUID()
        {
            Guid obj = Guid.NewGuid();
            return obj.ToString();  
        }



    }
}