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
    /// Summary description for SerialNumber class goes here.
    /// </summary>
    public class SerialNumber
    {

        // -------------------------------------------------------------------------------------------------------
        /// <summary>
        /// Pass error message, if any, back to the calling routine.
        /// </summary>
        public string ErrorMessage
        {
            get { return _error_message; }
        }

        // -------------------------------------------------------------------------------------------------------
        private string _serial_number = "";
        private string _error_message = "";



        public SerialNumber(string SerialNumber)
        {
            _serial_number = SerialNumber.ToUpper();
        }


        public bool Add()
        {
            return true;
        }

        /// <summary>
        /// Is the serial number already listed in MASTER_INDEX?
        /// </summary>
        public bool Exists()
        {
            //Is this serial number already listed in MASTER_INDEX?
            string sql = "SELECT * FROM MASTER_INDEX WHERE SERIAL_NUMBER = '" + _serial_number + "'";

            DbAccess db = new DbAccess();

            DataTable dt = new DataTable();

            dt = db.GetData(sql);

            // If there are rows in the table, then this serial number is already listed in the MASTER_INDEX table.
            if (dt.Rows.Count > 0)
                return true;
            else
                return false;
        }




        /// <summary>
        /// Is the serial number in a known valid format?
        /// </summary>
        public bool IsValid()
        {

            string code_plant;
            string code_year;
            string code_week;
            string code_day;

            string plants = "BEF";
            string years = "ABCDEFGHJKLMNLPQRSTUVWXY";
            string numbers = "0123456789";

            // Initialize.
            _error_message = "";


            // Evaluate serial number of length 10.
            if (_serial_number.Length == 10)
            {
                code_plant = _serial_number.Substring(0, 1);
                code_year = _serial_number.Substring(1, 1);
                code_week = _serial_number.Substring(2, 2);
                code_day = _serial_number.Substring(4, 1);

                // Character 0: Plant code
                if (!(plants.IndexOf(code_plant) > -1))
                {
                    _error_message = "Invalid plant code character.";
                    return false;
                }

                // Character 1: Year code
                if (!(years.IndexOf(code_year) > -1))
                {
                    _error_message = "Invalid year code character.";
                    return false;
                }

                // Character 3: Week - part 1.
                if (! (numbers.IndexOf(code_week.Substring(0,1)) > -1) )
                {
                    _error_message = "Invalid week code character.";
                    return false;
                }

                // Character 3: Week - part 2.
                if (! (numbers.IndexOf(code_week.Substring(1, 1)) > -1) )
                {
                    _error_message = "Invalid week code character.";
                    return false;
                }

                // Character 5: Day.
                if (! (numbers.IndexOf(code_day) > -1) )
                {
                    _error_message = "Invalid day code character.";
                    return false;
                }

                // Valid serial number
                return true;

            }
            else
            {
                _error_message = "Invalid serial number length.";
                return false;
            }


        }


        /// <summary>
        /// Try to determine part number if this is a long vendor serial number
        /// </summary>
        public string GetPartNumber()
        {
            string default_value = "";
            string sql;

            // Stop here if this is not a long serial number.
            if (_serial_number.Length <= 10) return default_value;

            sql = "SELECT PART_NUMBER, CROSS_REFERENCE, DESCRIPTION " +
                  "FROM PART_NUMBERS " +
                  "WHERE(((Left('730-05214-120021846A03', Len([PART_NUMBER]))) = [PART_NUMBER]))";

            sql = "SELECT PART_NUMBER, CROSS_REFERENCE, DESCRIPTION " +
                  "FROM PART_NUMBERS " +
                  "WHERE Left( '" + _serial_number + "', Len( [PART_NUMBER] ) ) = [PART_NUMBER]";

            sql = "SELECT PART_NUMBER, DESCRIPTION " +
                  "FROM PART_NUMBERS " +
                  "WHERE Left( '" + _serial_number + "', Len( [SERIAL_NUMBER_STARTS_WITH] ) ) = [SERIAL_NUMBER_STARTS_WITH]";


            DbAccess db = new DbAccess();

            DataTable dt =  db.GetData(sql);

            if (dt.Rows.Count > 0)
                default_value = dt.Rows[0]["PART_NUMBER"].ToString();

            return default_value;

        }




    }

}