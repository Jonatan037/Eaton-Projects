using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;


using System.Web.UI.WebControls;

namespace Tracks.DAL
{
    // This class is not currently being used, but is set up in case we need to stop using Session Variables.

    // Examples:

    // Label1.Text = SessionState.GetState(Master, SessionState.SessionVariableName.SERIAL_NUMBER);

    // SessionState.SetState(Master, SessionState.SessionVariableName.SERIAL_NUMBER, "From code behind");

    // <asp:HiddenField ID="SESSION_STATE_SERIAL_NUMBER" runat="server"/>



    /// <summary>
    /// Summary description for SessionState
    /// </summary>
    public static class SessionState
    {
        public enum SessionVariableName
        {
            BUILD_REPORT_ID,
            COMPONENT_ID,
            CORRECTIVE_ACTION_ID,

            ISSUE_REPORT_ID,
            ISSUE_REPORT_PANEL_STATE,

            LABOR_HOUR_ID,
            MASTER_INDEX_ID,
            SERIAL_NUMBER,
            TEST_COMPLETE_REPORT_ID
        }


        private const string _Prefix = "SESSION_STATE_";

        public static string GetState(System.Web.UI.MasterPage Master, SessionVariableName Name )
        {
            //<asp:HiddenField ID="SESSION_SERIAL_NUMBER" runat="server" Value ="testing hidden field on master"/>

                HiddenField hf;

                hf = (HiddenField) Master.FindControl(_Prefix + Name.ToString());

                return hf.Value.ToString();  
        }

        public static void SetState(System.Web.UI.MasterPage Master, SessionVariableName Name, String Value)
        {
            //<asp:HiddenField ID="SESSION_SERIAL_NUMBER" runat="server" Value ="testing hidden field on master"/>

            HiddenField hf;

            hf = (HiddenField)Master.FindControl(_Prefix + Name.ToString());

            hf.Value = Value;
        }

    }









}