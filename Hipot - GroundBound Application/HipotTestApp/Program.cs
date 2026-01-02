using System;
using System.Windows.Forms;
using HipotTestApp.Data;
using HipotTestApp.Forms;

namespace HipotTestApp
{
    /// <summary>
    /// Application entry point for Hipot Test System
    /// </summary>
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            // Verify database connection on startup
            if (!VerifyDatabaseConnection())
            {
                MessageBox.Show(
                    "Unable to connect to the database.\n\n" +
                    "Please verify:\n" +
                    "1. SQL Server is running\n" +
                    "2. The Phoenix database exists\n" +
                    "3. Your network connection is working\n\n" +
                    "Contact IT Support if the problem persists.",
                    "Database Connection Error",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            // Application loop - allows for logout and re-login
            bool continueRunning = true;
            while (continueRunning)
            {
                // Show login form
                using (var loginForm = new LoginForm())
                {
                    if (loginForm.ShowDialog() == DialogResult.OK)
                    {
                        var user = loginForm.AuthenticatedUser;
                        
                        // Show main form
                        using (var mainForm = new MainForm(user))
                        {
                            var result = mainForm.ShowDialog();
                            
                            // If user logged out (DialogResult.Retry), show login again
                            // Otherwise, exit the application
                            if (result != DialogResult.Retry)
                            {
                                continueRunning = false;
                            }
                        }
                    }
                    else
                    {
                        // User cancelled login
                        continueRunning = false;
                    }
                }
            }
        }

        /// <summary>
        /// Verifies database connection is available
        /// </summary>
        private static bool VerifyDatabaseConnection()
        {
            try
            {
                using (var db = new DatabaseHelper())
                {
                    return db.TestConnection();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Database connection error: {ex.Message}");
                return false;
            }
        }
    }
}
