using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

public partial class Tracks_ATE_Test_ATE_Create : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {

    }

    protected void Button1_Click(object sender, EventArgs e)
    {
        string serial_number = "EEe";
        string part_number = "zzzzzzzzzzzzz";
        string time_stamp = DateTime.Now.ToString();
        string passed_test = "0";
        string employee_id = "E0000000";
        string record_type = "2";
        string program_name = "test program";

        //string url = "Create_IssueReport.aspx?SN=robert&PN=testPN";

        // serial number, part number, timestamp, passed [1 for passeed, 0 for failed], employee id.
        //string url = "Create_IssueReport.aspx?SN=" + serial_number + "&PN=" + part_number + "&TS=" + time_stamp + "&PASSED=" + passed_test + "&EN=" + employee_id;

        //string url = "Create_IssueReport.aspx?SN=" + serial_number + "&PN=" + part_number + "&TS=" + time_stamp + "&PASSED=" + passed_test + "&EN=" + employee_id + "&RecordType=" + record_type;

        string url = "Create_IssueReport.aspx?SN=" + serial_number + "&PN=" + part_number + "&TS=" + time_stamp + "&PASSED=" + passed_test + "&EN=" + employee_id + "&RecordType=" + record_type + "&ProgramName=" + program_name;

        //string url ="Create_IssueReport?SN=EP032A0004_Assembly_Test&PN=P-103002027&TS=1/15/2020 3:05:35 PM&PASSED=0&EN=79511&RecordType=2";

        Response.Redirect(url);

    }
}