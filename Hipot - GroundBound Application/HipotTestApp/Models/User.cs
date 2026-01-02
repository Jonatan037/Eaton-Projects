using System;

namespace HipotTestApp.Models
{
    /// <summary>
    /// Represents a user in the system
    /// </summary>
    public class User
    {
        public int UserID { get; set; }
        public string ENumber { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string Department { get; set; }
        public string JobRole { get; set; }
        public string TestLine { get; set; }
        public string UserCategory { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedDate { get; set; }

        /// <summary>
        /// Display name for the user
        /// </summary>
        public string DisplayName => $"{FullName} ({ENumber})";
    }
}
