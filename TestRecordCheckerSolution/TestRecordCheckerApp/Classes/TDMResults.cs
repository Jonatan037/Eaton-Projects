using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TestRecordCheckerApp.Classes
{
    public class TDMResults
    {
        public static bool TDM_HasPassTestRecord(string ResultsName, string SN)
        {
            string sWorkingFolder = Directory.GetCurrentDirectory();
            string sWebServicePath = "\"" + sWorkingFolder + "\\TDM_RecordCheck\\IES_TDM.exe" + "\"";

            bool HasPassTestRecord = false;

            Process myProcess = new Process();
            myProcess.StartInfo.FileName = sWebServicePath;
            myProcess.StartInfo.Arguments = "\"" + ResultsName + "\" \"" + SN + "\"";
            myProcess.StartInfo.UseShellExecute = false;
            myProcess.StartInfo.CreateNoWindow = true;
            myProcess.StartInfo.RedirectStandardInput = true;
            myProcess.StartInfo.RedirectStandardOutput = true;
            myProcess.StartInfo.RedirectStandardError = true;

            string viewArguments = myProcess.StartInfo.Arguments;

            myProcess.Start();

            string output = myProcess.StandardOutput.ReadToEnd();

            myProcess.Close();

            if (output.IndexOf("Status = Passed") > 25 && output.Contains("Result = Passed"))
            {
                HasPassTestRecord = true;
            }
            else
            {
                HasPassTestRecord = false;
            }

            return HasPassTestRecord;
        }
    }
}