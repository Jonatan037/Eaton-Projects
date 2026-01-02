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
    /// Summary description for PartNumbers
    /// </summary>
    public class PartNumbers
    {
        private string _error_message = "";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }

        }

        public PartNumbers()
        {
            _db = new DbAccess();
        }

        public bool IsListed(string PartNumber)
        {
            string sql;
            DataTable dt;

            sql = "SELECT * FROM PART_NUMBERS WHERE PART_NUMBER = '" + PartNumber + "'";
            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            dt = _db.GetData(sql);
            _error_message = _db.ErrorMessage;

            if (dt.Rows.Count > 0)
                return true;
            else
                return false;
        }


        public bool Add(string PartNumber)
        {
            string sql = "";

            if (IsListed(PartNumber)) return true;

            sql = "INSERT INTO PART_NUMBERS (PART_NUMBER) " +
                  "VALUES(@PART_NUMBER)";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);

            _db.ExecuteNonQuery(command);

            _error_message = _db.ErrorMessage;

            if (_error_message == "")
                return true;
            else
                return false;

        }

    }
}