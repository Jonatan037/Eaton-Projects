using System;
using System.Data;
using System.IO;
using System.Linq;

namespace TestRecordCheckerApp.Classes
{
    public class ValidationLogReader
    {
        private readonly string logPath;

        public ValidationLogReader(string logPath = "validation_log.csv")
        {
            this.logPath = logPath;
        }

        public DataTable GetTodaysValidations()
        {
            var today = DateTime.Today;
            var table = new DataTable();
            table.Columns.Add("Serial Number");
            table.Columns.Add("Check Status");
            table.Columns.Add("DateTime");
            table.Columns.Add("Verifier");

            if (File.Exists(logPath))
            {
                var lines = File.ReadAllLines(logPath).Skip(1); // Skip header

                var filtered = lines
                    .Select(line => line.Split(','))
                    .Where(parts => parts.Length == 10 && DateTime.TryParse(parts[8], out DateTime timestamp) && timestamp.Date == today)
                    .OrderByDescending(parts => DateTime.Parse(parts[8])); // Sort by Verification DateTime descending

                foreach (var parts in filtered)
                {
                    table.Rows.Add(parts[6], parts[7], parts[8], parts[5]); // Serial Number, Check Status, DateTime, Verifier Name
                }
            }

            return table;
        }



    }
}
