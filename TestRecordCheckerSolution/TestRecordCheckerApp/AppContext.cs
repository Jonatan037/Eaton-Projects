using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace TestRecordCheckerApp
{
    public class AppContext : ApplicationContext
    {

        private logInForm loginForm;
        private mainForm mainForm;

        public AppContext()
        {
            ShowLoginForm();
        }

        private void ShowLoginForm()
        {
            loginForm = new logInForm();
            loginForm.LoginSuccessful += OnLoginSuccessful;
            loginForm.FormClosed += (s, e) => ExitThread(); // Exit app if login form is closed
            loginForm.Show();
        }

        private void OnLoginSuccessful(object sender, LoginEventArgs u)
        {
            loginForm.Hide();

            mainForm = new mainForm(u.EmployeeName, u.ScannedID);
            mainForm.FormClosed += (s, e) =>
            {
                loginForm.ResetForm();
                loginForm.Show(); // Show login again on logout
            };
            mainForm.LogoutRequested += OnLogoutRequested;
            mainForm.Show();
        }

        private void OnLogoutRequested(object sender, EventArgs e)
        {
            mainForm.Close(); // This triggers showing the login form again
        }

    }
}
