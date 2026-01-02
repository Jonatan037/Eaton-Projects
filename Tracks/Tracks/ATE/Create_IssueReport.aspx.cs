using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using Tracks.DAL;

public partial class Tracks_ATE_Create_IssueReport : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

#if false
        foreach(string name in Request.ServerVariables)
        {
             Response.Write(name + ": " + Request.ServerVariables[name].ToString() + "<br/>"); 
        }
#endif

        // Get the PN and serial number from the request strings.
        string serial_number = Request.QueryString["SN"];
        string part_number = Request.QueryString["PN"];

        string time_stamp = Request.QueryString["TS"];

        // 1 = passed, 0 = failed
        string passed_test = Request.QueryString["PASSED"];

        string employee_id = Request.QueryString["EN"];

        string record_type = Request.QueryString["RecordType"];

        string program_name = Request.QueryString["ProgramName"];

        //Response.Write(serial_number + "<br>");
        //Response.Write(part_number + "<br>");

        // Return if either the part number or serial number is null.
        if (serial_number == null) return;
        if (part_number == null) return;

        // Trim the serial number and put in upper case.
        serial_number = serial_number.Trim();
        serial_number = serial_number.ToUpper();

        // Trim the part number and put in upper case.
        part_number = part_number.Trim();
        part_number = part_number.ToUpper();

        // Return if either the part number or serial number is empty.
        if (serial_number == "" || part_number == "") return;


        if (time_stamp == null) time_stamp = DateTime.Now.ToString();

        if (passed_test == null) passed_test = "1";

        if (employee_id == null) employee_id = "0";

        employee_id = employee_id.ToUpper();

        if (record_type == null) record_type = "0";

        if (program_name == null) program_name = "";

        ATE ate = new ATE();

        // Create a new issue report.
        //ate.Add(serial_number, part_number);

        // Create master index and issue report entries.
        ate.Add(serial_number, part_number, time_stamp, passed_test, employee_id, record_type, program_name);

    }
}