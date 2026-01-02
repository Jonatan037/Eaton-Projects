using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestRecordCheckerApp
{
    public class LoginEventArgs : EventArgs
    {
        public string EmployeeName { get; }
        public string ScannedID { get; }

        public LoginEventArgs(string employeeName, string scannedID)
        {
            EmployeeName = employeeName;
            ScannedID = scannedID;
        }
    }

}
