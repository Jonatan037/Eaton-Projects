using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using System.Security.Principal;

namespace Tracks.BLL
{
    /// <summary>
    /// Summary description for UserPermissions
    /// </summary>
    public static class UserPermissions
    {

        public static bool IsAdministrator(IPrincipal User)
        {
            string[] roles = new string[1] { "Administrators" };

            // Loop over strings.
            foreach (string s in roles)
            {
                if (User.IsInRole(s)) return true;
            }

            // User not in the specified roles.
            return false;

        }


        public static bool CanEditIssueReport(IPrincipal User)
        {
            string[] roles = new string[6] { "Administrators", "Tracks_Admins", "Tracks_Techs", "Tracks_Users", "TestTechs", "QualityEngineers"};

            // Loop over strings.
            foreach (string s in roles)
            {
                if (User.IsInRole(s)) return true;
            }

            // User not in the specified roles.
            return false;

        }

        public static bool CanEditQualityOptions(IPrincipal User)
        {
            string[] roles = new string[4] { "Administrators", "Tracks_Admins", "Tracks_Techs", "QualityEngineers"};

            // Loop over strings.
            foreach (string s in roles)
            {
                if (User.IsInRole(s)) return true;
            }

            // User not in the specified roles.
            return false;

        }

        public static bool CanDeleteIssueReport(IPrincipal User)
        {
            string[] roles = new string[1] { "Tracks_Admins"};

            // Loop over strings.
            foreach (string s in roles)
            {
                if (User.IsInRole(s)) return true;
            }

            // User not in the specified roles.
            return false;

        }
    }

}