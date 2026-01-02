using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Web.UI;
using System.Web.UI.WebControls;



/// <summary>
/// Summary description for DateChecker
/// </summary>
public class DateChecker
{
    public bool IsValidDateRange(ref TextBox start_date, ref TextBox end_date)
    {
        bool valid_start_date;
        bool valid_end_date;

        // Check the validity of each date.
        valid_start_date = IsValidDate(ref start_date);
        valid_end_date = IsValidDate(ref end_date);

        // Both dates must be valid.
        if (!valid_start_date || !valid_end_date) return false;

        return true;

    }


    public bool IsValidDate( ref TextBox date)
    {
        // If the text in the TextBox is not a valid date, then write message to the TextBox
        if ( !IsValidDate(date.Text) )
        {
            date.Text = "Enter a valid date";
            return false;
        }
        else 
            return true;
    }    


    public bool IsValidDate(string date)
    {

        DateTime result;    // Contains the parsed value of the string.
        bool valid_date;    // Validity state.

        // Verify that the string is formatted as a date.
        valid_date = DateTime.TryParse(date, out result);

        // Return false if the string was not a properly formatted date.
        if (!valid_date) return false;


        // Verify that the date is within acceptable range.
        if (result.CompareTo(DateTime.Parse("1/1/2000")) < 1) return false;

        // Valid date.
        return true;
    }

}