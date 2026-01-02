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
    /// Summary description for MasterIndex
    /// </summary>
    public class MasterIndex
    {

        public enum FlagName
        {
            FAILED,
            HAS_ATE_FAILURE_REPORT,
            HAS_ISSUE_REPORT,
            HAS_TEST_COMPLETE_REPORT,
            REQUIRES_ATE_RECORD,
            LAST_TEST_STATUS
        }


        private string _error_message = "";
        private DbAccess _db;

        public string ErrorMessage
        {
            get { return _error_message; }

        }
        public MasterIndex()
        {
            _db = new DbAccess();
        }

        // For use by ATE.
        // Add new serial number and associated data
        // Return true if the serial number already exists or if it was successfully added.
        // SerialNumber and PartNumber are required fields, everything else can be empty string.
        public bool AddFromATE(string SerialNumber, string PartNumber, string TimeStamp)
        {


            SerialNumber SN = new SerialNumber(SerialNumber);

            string sql;

            // Return true if the serial number already exists.
            if (SN.Exists()) return true;


            sql = "INSERT INTO [MASTER_INDEX] " +
                  "( [SERIAL_NUMBER], [PART_NUMBER], [CREATION_TIMESTAMP], [FIRST_TEST_DATE], [FIRST_TEST_DATE_NOTE] ) " +
                  "VALUES ( @SERIAL_NUMBER, @PART_NUMBER, @CREATION_TIMESTAMP, @FIRST_TEST_DATE, @FIRST_TEST_DATE_NOTE )";


            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@CREATION_TIMESTAMP", TimeStamp);
            command.Parameters.AddWithValue("@FIRST_TEST_DATE", TimeStamp);
            command.Parameters.AddWithValue("@FIRST_TEST_DATE_NOTE", "FIRST_TEST_DATE is from ATE");


            // Execute the command to add the new serial number.
            _error_message = _db.ExecuteNonQuery(command);

            // Check that the serial number was successfully added.
            if (SN.Exists())
            {
                UpdateMetaData(SerialNumber);
                return true;
            }
            else
                return false;
        }

        // Add new serial number and associated data
        // Return true if the serial number already exists or if it was successfully added.
        // SerialNumber and PartNumber are required fields, everything else can be empty string.
        public bool Add(string SerialNumber, string PartNumber, string ProductionOrderNumber, string SalesOrderNumber, string Notes)
        {
            // Upper case
            SerialNumber = SerialNumber.ToUpper();
            PartNumber = PartNumber.ToUpper();

            // Get rid of _Assembly_Test tag for RPO.
            if (SerialNumber.Substring(0,1) == "E")
            {
                SerialNumber = SerialNumber.Substring(0, 10);
            }

            SerialNumber SN = new SerialNumber(SerialNumber);

            string sql;

            // Return true if the serial number already exists.
            if (SN.Exists()) return true;


            sql = "INSERT INTO [MASTER_INDEX] " +
                  "( [SERIAL_NUMBER], [PART_NUMBER], [PRODUCTION_ORDER_NUMBER], [SALES_ORDER_NUMBER], [NOTES] ) " +
                  "VALUES ( @SERIAL_NUMBER, @PART_NUMBER, @PRODUCTION_ORDER_NUMBER, @SALES_ORDER_NUMBER, @NOTES )";


            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;
            command.Parameters.AddWithValue("@SERIAL_NUMBER", SerialNumber);
            command.Parameters.AddWithValue("@PART_NUMBER", PartNumber);
            command.Parameters.AddWithValue("@PRODUCTION_ORDER_NUMBER", ProductionOrderNumber);
            command.Parameters.AddWithValue("@SALES_ORDER_NUMBER", SalesOrderNumber);
            command.Parameters.AddWithValue("@NOTES", Notes);

            // Execute the command to add the new serial number.
            _error_message = _db.ExecuteNonQuery(command);

            // Check that the serial number was successfully added.
            if (SN.Exists())
            {
                UpdateMetaData(SerialNumber);
                return true;
            }
            else
                return false;
        }


        // Update meta-data fields using data from the PART_NUMBERS table.
        public void UpdateMetaData(string SerialNumber = "")
        {
            string sql;
            string criteria = " WHERE LOCKED = 0 ";

            // Create the criteria if a serial number was include as a parameter.
            if (SerialNumber != "")
                criteria = " WHERE SERIAL_NUMBER = '" + SerialNumber + "'";
            else
                criteria = " WHERE LOCKED = 0";

            sql = "UPDATE MASTER_INDEX " +
                  "SET " +
                  "MASTER_INDEX.PLANT = [PART_NUMBERS].[PLANT], " +
                  "MASTER_INDEX.FAMILY = [PART_NUMBERS].[FAMILY], " +
                  "MASTER_INDEX.CATEGORY = [PART_NUMBERS].[CATEGORY], " +
                  "MASTER_INDEX.SUBCATEGORY = [PART_NUMBERS].[SUBCATEGORY], " +
                  "MASTER_INDEX.DESCRIPTION = [PART_NUMBERS].[DESCRIPTION], " +
                  "MASTER_INDEX.MATERIAL_TYPE = [PART_NUMBERS].[MATERIAL_TYPE], " +
                  "MASTER_INDEX.CROSS_REFERENCE = [PART_NUMBERS].[CROSS_REFERENCE], " +
                  "MASTER_INDEX.INCLUDE_IN_FPY = [PART_NUMBERS].[INCLUDE_IN_FPY], " +
                  "MASTER_INDEX.COST = [PART_NUMBERS].[COST], " +
                  "MASTER_INDEX.REQUIRES_ATE_RECORD = [PART_NUMBERS].[REQUIRES_ATE_RECORD] " +
                  "FROM MASTER_INDEX INNER JOIN PART_NUMBERS ON MASTER_INDEX.PART_NUMBER = PART_NUMBERS.PART_NUMBER " +
                  criteria;


            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message =_db.ExecuteNonQuery(command);

        }



        public bool SetFirstTestDate(string MasterIndexID, string TimeStamp, string SourceName)
        {
            bool return_value = false;

            string sql;

            sql = "UPDATE MASTER_INDEX " +
                  "SET " +
                     "FIRST_TEST_DATE = '" + TimeStamp + "', " +
                     "FIRST_TEST_DATE_NOTE = 'FIRST_TEST_DATE is from " + SourceName + "' " +
                  "WHERE MASTER_INDEX_ID = " + MasterIndexID + " AND " +
                  "( ( FIRST_TEST_DATE IS NULL ) OR ( '" + TimeStamp + "' < FIRST_TEST_DATE ) )";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);

            // If no error occured, return value is true.
            if (_error_message == "") return_value = true;

            return return_value;
        }

        public void UpdateFlag(string MasterIndexID, FlagName Name, bool Value)
        {
            string sql;

            string FlagName = Name.ToString();

            // Convert bool to int.
            int testInt = Value ? 1 : 0;
            
            sql = "UPDATE MASTER_INDEX " +
                  "SET " + FlagName + " = 1 " +
                  "WHERE MASTER_INDEX_ID = " + MasterIndexID;

            sql = "UPDATE MASTER_INDEX " +
                  "SET " + FlagName + " = " + testInt.ToString() + " " +
                  "WHERE MASTER_INDEX_ID = " + MasterIndexID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            _error_message = _db.ExecuteNonQuery(command);
        }

        public bool GetFlag(string MasterIndexID, FlagName Name)
        {
            string sql;
            string FlagName = Name.ToString();

            int return_value;

            sql = "SELECT " + FlagName + " FROM MASTER_INDEX " +
                  "WHERE MASTER_INDEX_ID = " + MasterIndexID;

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            return_value = _db.ExecuteScalar(command);

            // Convert the return value to boolean.
            return ( return_value == 0 ? false : true);
        }

        public bool GetFlagBySerialNumber(string SerialNumber, FlagName Name)
        {
            string sql;
            string FlagName = Name.ToString();

            int return_value;

            sql = "SELECT " + FlagName + " FROM MASTER_INDEX " +
                  "WHERE SERIAL_NUMBER = '" + SerialNumber + "'";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            return_value = _db.ExecuteScalar(command);

            _error_message = _db.ErrorMessage;

            // Convert the return value to boolean.
            return (return_value == 0 ? false : true);
        }

        public string GetMasterIndexID(string SerialNumber)
        {
            string id = "0";
            string sql;

            sql = "SELECT [MASTER_INDEX_ID] FROM MASTER_INDEX WHERE SERIAL_NUMBER = '" + SerialNumber + "'";

            SqlCommand command = new SqlCommand();

            command.CommandType = CommandType.Text;
            command.CommandText = sql;

            id = _db.ExecuteScalar(command).ToString();

            return id;

        }

    }

}
